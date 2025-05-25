//
//  PhotoListViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import SwiftUI
import Photos

// 사진 업로드를 관리하는 ViewModel
@Observable
class PhotoListVM {
    // 서비스
    private let uploadService: GalleryUploadServiceProtocol
    private let uploadedPhotoManager = PhotoStorageService()

    private let userId = "user123"
    var photoAssets: [PhotoAssetModel] = []
    var isUploading = false
    var showingPermissionAlert = false
    var showingDuplicateAlert = false
    var showingUploadSuccess = false
    var uploadSuccessCount = 0

    init(uploadService: GalleryUploadServiceProtocol = GalleryUploadService()) {
        self.uploadService = uploadService
    }

    var hasSelectedPhotos: Bool {
        photoAssets.contains(where: { $0.isSelected })
    }

    // MARK: - 사진첩 접근 권한 요청
    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self?.fetchPhotos()
                case .denied, .restricted:
                    self?.showingPermissionAlert = true
                default:
                    break
                }
            }
        }
    }

    // MARK: - 사진 가져오기
    private func fetchPhotos() {
        // 1. 사진첩에서 이미지 에셋 가져오기
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        // 2. 에셋을 PhotoAssetModel로 변환
        var assets: [PhotoAssetModel] = []
        fetchResult.enumerateObjects { asset, _, _ in
            // 변수 이름 수정: is Uploade → isUploaded
            let isUploaded = self.uploadedPhotoManager.isPhotoUploaded(assetId: asset.localIdentifier)
            assets.append(PhotoAssetModel(asset: asset, isSelected: false, isUploaded: isUploaded))
        }

        // 3. 메인 스레드에서 상태 업데이트
        DispatchQueue.main.async {
            self.photoAssets = assets
        }
    }

    // MARK: - 사진 탭 처리
    func handleTap(assetId: String) {
        guard let index = photoAssets.firstIndex(where: { $0.id == assetId }) else { return }
        if photoAssets[index].isUploaded || uploadedPhotoManager.isPhotoUploaded(assetId: assetId) {
            showingDuplicateAlert = true
        } else {
            photoAssets[index].isSelected.toggle()
        }
    }

    // MARK: - 선택된 사진 업로드
    func uploadSelectedPhotos(onComplete: ((UploadCompleteResponse) -> Void)? = nil) async {
        guard hasSelectedPhotos, !isUploading else { return }
        isUploading = true

        do {
            // 1. 선택된 에셋
            let selectedAssetModels = photoAssets.filter { $0.isSelected }
            let selectedAssets = selectedAssetModels.map { $0.asset }

            // 2. 이미지 변환 및 메타데이터 생성 (병렬 처리)
            var images: [UIImage] = []
            var imageInfos: [PresignedURLRequestDTO] = []
            var assetIds: [String] = []

            // TaskGroup으로 병렬 변환
            try await withThrowingTaskGroup(of: (UIImage, PresignedURLRequestDTO, String).self) { group in
                for asset in selectedAssets {
                    group.addTask {
                        guard let image = await self.requestUIImage(from: asset) else {
                            throw NSError(domain: "PhotoListViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 변환 실패"])
                        }
                        let id = asset.localIdentifier.components(separatedBy: "/").first ?? "img"
                        let timestamp = Int(Date().timeIntervalSince1970)
                        let fileExtension = self.getImageFileExtension(from: asset)
                        let fileName = "\(id)_\(timestamp).\(fileExtension)"
                        let contentType = fileExtension == "png" ? "image/png" : "image/jpeg"
                        return (image, PresignedURLRequestDTO(fileName: fileName, contentType: contentType), asset.localIdentifier)
                    }
                }

                // 변환 결과 수집
                for try await (image, info, assetId) in group {
                    images.append(image)
                    imageInfos.append(info)
                    assetIds.append(assetId)
                }
            }

            // 3. Presigned URL 요청
            let presignedURLs = try await uploadService.requestPresignedURLs(imageInfos: imageInfos)

            // 4. S3 업로드 (병렬 처리)
            try await withThrowingTaskGroup(of: Void.self) { group in
                for (index, presignedURL) in presignedURLs.enumerated() where index < images.count {
                    group.addTask {
                        try await self.uploadService.uploadImageToS3(image: images[index], presignedURL: presignedURL)
                    }
                }
                try await group.waitForAll()
            }

            // 5. 업로드 완료 알림
            let now = ISO8601DateFormatter().string(from: Date())
            let uploadedInfos = presignedURLs.enumerated().map { (index, presignedURL) in
                UploadCompleteRequest.UploadedPhotoInfo(
                    photoId: presignedURL.photoId,
                    photoUrl: presignedURL.photoUrl,
                    uploadAt: now
                )
            }
            let response = try await uploadService.notifyUploadComplete(userId: userId, uploadedPhotos: uploadedInfos)

            // 6. 상태 및 로컬 정보 갱신
            let uploadedPhotoIds = Set(response.newPhoto.map { $0.photoId })
            for (index, assetId) in assetIds.enumerated() {
                if index < presignedURLs.count,
                   uploadedPhotoIds.contains(presignedURLs[index].photoId),
                   let assetIndex = photoAssets.firstIndex(where: { $0.asset.localIdentifier == assetId }) {
                    photoAssets[assetIndex].isUploaded = true
                    photoAssets[assetIndex].isSelected = false
                    let uploadedPhoto = UploadedLocalPhotoInfo(
                        id: assetId,
                        photoId: presignedURLs[index].photoId,
                        photoUrl: presignedURLs[index].photoUrl,
                        uploadedAt: Date()
                    )
                    uploadedPhotoManager.saveUploadedPhoto(uploadedPhoto)
                }
            }
            uploadSuccessCount = uploadedPhotoIds.count
            showingUploadSuccess = true
            onComplete?(response)
        } catch {
            print("업로드 실패: \(error.localizedDescription)")
            // 사용자에게 에러 알림 (예: self.errorMessage = "업로드 실패: \(error.localizedDescription)")
        }
        isUploading = false
    }

    // MARK: - PHAsset → UIImage 비동기 변환 (최적화)
    private func requestUIImage(from asset: PHAsset) async -> UIImage? {
        let targetSize = CGSize(width: 1920, height: 1080) // 최대 1080p로 리사이징
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast // 빠른 리사이징
        options.isNetworkAccessAllowed = false // iCloud 다운로드 비활성화 (로컬 우선)
        options.normalizedCropRect = CGRect(x: 0, y: 0, width: 1, height: 1)

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                // JPEG 압축 적용
                if let image = image,
                   let data = image.jpegData(compressionQuality: 0.8),
                   let compressedImage = UIImage(data: data) {
                    continuation.resume(returning: compressedImage)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    // MARK: - 이미지 파일 확장자 결정
    private func getImageFileExtension(from asset: PHAsset) -> String {
        if let uti = asset.value(forKey: "uniformTypeIdentifier") as? String {
            if uti == "public.png" { return "png" }
        }
        return "jpg"
    }
}
