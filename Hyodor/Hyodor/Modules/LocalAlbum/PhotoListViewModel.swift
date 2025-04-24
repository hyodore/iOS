//
//  PhotoListViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import SwiftUI
import Photos

class PhotoListViewModel: ObservableObject {
    // 서비스
    private let uploadService: GalleryUploadServiceProtocol
    private let uploadedPhotoManager = UploadedPhotoManager()

    @Published var photoAssets: [PhotoAssetModel] = []
    @Published var isUploading = false
    @Published var showingPermissionAlert = false
    @Published var showingDuplicateAlert = false
    @Published var showingUploadSuccess = false
    @Published var uploadSuccessCount = 0

    private let userId = "user123"

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
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var assets: [PhotoAssetModel] = []
        fetchResult.enumerateObjects { asset, _, _ in
            let isUploaded = self.uploadedPhotoManager.isPhotoUploaded(assetId: asset.localIdentifier)
            assets.append(PhotoAssetModel(asset: asset, isSelected: false, isUploaded: isUploaded))
        }
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

    // MARK: - 업로드 처리 (async/await)
    @MainActor
    func uploadSelectedPhotos(onComplete: ((UploadCompleteResponse) -> Void)? = nil) async {
        guard hasSelectedPhotos, !isUploading else { return }
        isUploading = true

        // 1. 선택된 에셋
        let selectedAssetModels = photoAssets.filter { $0.isSelected }
        let selectedAssets = selectedAssetModels.map { $0.asset }

        // 2. 이미지 변환 (비동기)
        var images: [UIImage] = []
        var imageInfos: [[String: String]] = []

        for asset in selectedAssets {
            if let image = await requestUIImage(from: asset) {
                images.append(image)
                let id = asset.localIdentifier.components(separatedBy: "/").first ?? "img"
                let timestamp = Int(Date().timeIntervalSince1970)
                let fileExtension = getImageFileExtension(from: asset)
                let fileName = "\(id)_\(timestamp).\(fileExtension)"
                let contentType = fileExtension == "png" ? "image/png" : "image/jpeg"
                imageInfos.append([
                    "fileName": fileName,
                    "contentType": contentType
                ])
            }
        }

        do {
            // 3. Presigned URL 요청
            let presignedURLs = try await uploadService.requestPresignedURLs(imageInfos: imageInfos)

            // 4. S3 업로드
            for (index, presignedURL) in presignedURLs.enumerated() where index < images.count {
                try await uploadService.uploadImageToS3(image: images[index], presignedURL: presignedURL)
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

            // 6. 상태/로컬 정보 갱신
            let uploadedPhotoIds = Set(response.newPhoto.map { $0.photoId })
            for (index, asset) in selectedAssets.enumerated() {
                if index < presignedURLs.count,
                   uploadedPhotoIds.contains(presignedURLs[index].photoId),
                   let assetIndex = photoAssets.firstIndex(where: { $0.asset.localIdentifier == asset.localIdentifier }) {
                    photoAssets[assetIndex].isUploaded = true
                    photoAssets[assetIndex].isSelected = false
                    let uploadedPhoto = UploadedLocalPhotoInfo(
                        id: asset.localIdentifier,
                        photoId: presignedURLs[index].photoId,
                        photoUrl: presignedURLs[index].photoUrl,
                        uploadedAt: Date()
                    )
                    uploadedPhotoManager.saveUploadedPhoto(uploadedPhoto)
                }
            }
            uploadSuccessCount = uploadedPhotoIds.count
            isUploading = false
            showingUploadSuccess = true
            onComplete?(response)
        } catch {
            print("업로드 실패: \(error.localizedDescription)")
            isUploading = false
            // 에러 처리 추가
        }
    }

    // MARK: - PHAsset → UIImage 비동기 변환
    private func requestUIImage(from asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    private func getImageFileExtension(from asset: PHAsset) -> String {
        if let uti = asset.value(forKey: "uniformTypeIdentifier") as? String {
            if uti == "public.png" { return "png" }
        }
        return "jpg"
    }
}
