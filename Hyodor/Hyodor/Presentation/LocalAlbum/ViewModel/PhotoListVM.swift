//
//  PhotoListViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import SwiftUI
import Photos

@Observable
class PhotoListVM {
    // Use Cases 및 Repository 의존성 주입
    private let photoRepository: PhotoRepository
    private let galleryRepository: GalleryRepository

    var photoAssets: [PhotoAssetModel] = []
    var isUploading = false
    var showingPermissionAlert = false
    var showingDuplicateAlert = false
    var showingUploadSuccess = false
    var uploadSuccessCount = 0

    init(
        photoRepository: PhotoRepository = PhotoRepositoryImpl(),
        galleryRepository: GalleryRepository = GalleryRepositoryImpl()
    ) {
        self.photoRepository = photoRepository
        self.galleryRepository = galleryRepository
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
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var assets: [PhotoAssetModel] = []
        fetchResult.enumerateObjects { asset, _, _ in
            let isUploaded = self.photoRepository.isPhotoUploaded(assetId: asset.localIdentifier)
            assets.append(PhotoAssetModel(asset: asset, isSelected: false, isUploaded: isUploaded))
        }

        DispatchQueue.main.async {
            self.photoAssets = assets
        }
    }

    // MARK: - 사진 탭 처리
    func handleTap(assetId: String) {
        guard let index = photoAssets.firstIndex(where: { $0.id == assetId }) else { return }
        if photoAssets[index].isUploaded || photoRepository.isPhotoUploaded(assetId: assetId) {
            showingDuplicateAlert = true
        } else {
            photoAssets[index].isSelected.toggle()
        }
    }

    // MARK: - 선택된 사진 업로드
    func uploadSelectedPhotos(onComplete: ((SyncResponseDTO) -> Void)? = nil) async {
        guard hasSelectedPhotos, !isUploading else { return }
        isUploading = true

        do {
            let selectedAssetModels = photoAssets.filter { $0.isSelected }
            let selectedAssets = selectedAssetModels.map { $0.asset }

            var images: [UIImage] = []
            var imageInfos: [ImageUploadRequestDTO] = []
            var assetIds: [String] = []

            // TaskGroup으로 병렬 변환
            try await withThrowingTaskGroup(of: (UIImage, ImageUploadRequestDTO, String).self) { group in
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
                        return (image, ImageUploadRequestDTO(fileName: fileName, contentType: contentType), asset.localIdentifier)
                    }
                }

                for try await (image, info, assetId) in group {
                    images.append(image)
                    imageInfos.append(info)
                    assetIds.append(assetId)
                }
            }

            // Presigned URL 요청
            let presignedURLs = try await galleryRepository.requestPresignedURLs(imageInfos: imageInfos)

            // S3 업로드 (병렬 처리)
            try await withThrowingTaskGroup(of: Void.self) { group in
                for (index, presignedURL) in presignedURLs.enumerated() where index < images.count {
                    group.addTask {
                        try await self.galleryRepository.uploadImageToS3(image: images[index], presignedURL: presignedURL)
                    }
                }
                try await group.waitForAll()
            }

            // 업로드 완료 알림
            let now = ISO8601DateFormatter().string(from: Date())
            let uploadedInfos = presignedURLs.enumerated().map { (index, presignedURL) in
                UploadedPhotoInfoDTO(
                    photoId: presignedURL.photoId,
                    photoUrl: presignedURL.photoUrl,
                    uploadAt: now
                )
            }
            let response = try await galleryRepository.notifyUploadComplete(userId: APIConstants.userId, uploadedPhotos: uploadedInfos)

            // 상태 및 로컬 정보 갱신
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
                    photoRepository.saveUploadedPhoto(uploadedPhoto)
                }
            }
            uploadSuccessCount = uploadedPhotoIds.count
            showingUploadSuccess = true
            onComplete?(response)
        } catch {
            print("업로드 실패: \(error.localizedDescription)")
        }
        isUploading = false
    }

    // MARK: - PHAsset → UIImage 비동기 변환 (최적화)
    private func requestUIImage(from asset: PHAsset) async -> UIImage? {
        let targetSize = CGSize(width: 1920, height: 1080)
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = false
        options.normalizedCropRect = CGRect(x: 0, y: 0, width: 1, height: 1)

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
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
