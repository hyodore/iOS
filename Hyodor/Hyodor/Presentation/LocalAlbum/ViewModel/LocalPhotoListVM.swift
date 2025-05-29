//
//  PhotoListViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import SwiftUI
import Photos

@Observable
class LocalPhotoListVM {
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

    func handleTap(assetId: String) {
        guard let index = photoAssets.firstIndex(where: { $0.id == assetId }) else { return }
        if photoAssets[index].isUploaded || photoRepository.isPhotoUploaded(assetId: assetId) {
            showingDuplicateAlert = true
        } else {
            photoAssets[index].isSelected.toggle()
        }
    }

    func uploadSelectedPhotos(onComplete: ((SyncResponseDTO) -> Void)? = nil) async {
        guard hasSelectedPhotos, !isUploading else { return }
        isUploading = true

        do {
            let selectedAssetModels = photoAssets.filter { $0.isSelected }
            let selectedAssets = selectedAssetModels.map { $0.asset }

            var images: [UIImage] = []
            var imageInfos: [ImageUploadRequestDTO] = []
            var assetIds: [String] = []

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

            let presignedURLs = try await galleryRepository.requestPresignedURLs(imageInfos: imageInfos)

            try await withThrowingTaskGroup(of: Void.self) { group in
                for (index, presignedURL) in presignedURLs.enumerated() where index < images.count {
                    group.addTask {
                        try await self.galleryRepository.uploadImageToS3(image: images[index], presignedURL: presignedURL)
                    }
                }
                try await group.waitForAll()
            }

            let now = ISO8601DateFormatter().string(from: Date())
            let uploadedInfos = presignedURLs.enumerated().map { (index, presignedURL) in
                UploadedPhotoInfoDTO(
                    photoId: presignedURL.photoId,
                    photoUrl: presignedURL.photoUrl,
                    uploadAt: now
                )
            }
            let response = try await galleryRepository.notifyUploadComplete(userId: APIConstants.userId, uploadedPhotos: uploadedInfos)

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

    private func getImageFileExtension(from asset: PHAsset) -> String {
        if let uti = asset.value(forKey: "uniformTypeIdentifier") as? String {
            if uti == "public.png" { return "png" }
        }
        return "jpg"
    }
}
