//
//  PhotoUploadUseCase.swift
//  Hyodor
//
//  Created by 김상준 on 6/12/25.
//

import Photos
import SwiftUI

enum PhotoUploadResult {
    case success(response: SyncResponseDTO, uploadedCount: Int)
    case failure(error: Error)
}

protocol PhotoUploadUseCase {
    func execute(assets: [PHAsset]) async -> PhotoUploadResult
}

class PhotoUploadUseCaseImpl: PhotoUploadUseCase {
    private let galleryRepository: GalleryRepository
    private let photoRepository: LocalPhotoRecordRepository


    init(
        galleryRepository: GalleryRepository = GalleryRepositoryImpl(),
        photoRepository: LocalPhotoRecordRepository
 = LocalPhotoRecordRepositoryImpl()
    ) {
        self.galleryRepository = galleryRepository
        self.photoRepository = photoRepository
    }

    func execute(assets: [PHAsset]) async -> PhotoUploadResult {
        do {
            let preparedData = try await prepareUploadData(from: assets)

            let presignedURLs = try await galleryRepository.requestPresignedURLs(imageInfos: preparedData.imageInfos)

            try await uploadImagesToS3(images: preparedData.images, presignedURLs: presignedURLs)

            let response = try await notifyServer(presignedURLs: presignedURLs)

            updateLocalState(response: response, assetIds: preparedData.assetIds, presignedURLs: presignedURLs)

            let uploadedCount = Set(response.newPhoto.map { $0.photoId }).count
            return .success(response: response, uploadedCount: uploadedCount)

        } catch {
            return .failure(error: error)
        }
    }

    private func prepareUploadData(from assets: [PHAsset]) async throws -> (images: [UIImage], imageInfos: [ImageUploadRequestDTO], assetIds: [String]) {
        var images: [UIImage] = []
        var imageInfos: [ImageUploadRequestDTO] = []
        var assetIds: [String] = []

        try await withThrowingTaskGroup(of: (UIImage, ImageUploadRequestDTO, String).self) { group in
            for asset in assets {
                group.addTask {
                    guard let image = await self.requestUIImage(from: asset) else {
                        throw NSError(domain: "PhotoUploadUseCase", code: 1, userInfo: [NSLocalizedDescriptionKey: "이미지 변환 실패: \(asset.localIdentifier)"])
                    }
                    let id = asset.localIdentifier.components(separatedBy: "/").first ?? "img"
                    let timestamp = Int(Date().timeIntervalSince1970)
                    let fileExtension = self.getImageFileExtension(from: asset)
                    let fileName = "\(id)_\(timestamp).\(fileExtension)"
                    let contentType = fileExtension == "png" ? "image/png" : "image/jpeg"

                    let imageInfo = ImageUploadRequestDTO(fileName: fileName, contentType: contentType)
                    return (image, imageInfo, asset.localIdentifier)
                }
            }

            for try await (image, info, assetId) in group {
                images.append(image)
                imageInfos.append(info)
                assetIds.append(assetId)
            }
        }
        return (images, imageInfos, assetIds)
    }

    private func uploadImagesToS3(images: [UIImage], presignedURLs: [PresignedURLResponseDTO]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for (index, presignedURL) in presignedURLs.enumerated() where index < images.count {
                group.addTask {
                    try await self.galleryRepository.uploadImageToS3(image: images[index], presignedURL: presignedURL)
                }
            }
            try await group.waitForAll()
        }
    }

    private func notifyServer(presignedURLs: [PresignedURLResponseDTO]) async throws -> SyncResponseDTO {
        let now = ISO8601DateFormatter().string(from: Date())
        let uploadedInfos = presignedURLs.map { presignedURL in
            UploadedPhotoInfoDTO(
                photoId: presignedURL.photoId,
                photoUrl: presignedURL.photoUrl,
                uploadAt: now
            )
        }
        return try await galleryRepository.notifyUploadComplete(userId: APIConstants.userId, uploadedPhotos: uploadedInfos)
    }

    private func updateLocalState(response: SyncResponseDTO, assetIds: [String], presignedURLs: [PresignedURLResponseDTO]) {
        let uploadedPhotoIds = Set(response.newPhoto.map { $0.photoId })
        for (index, assetId) in assetIds.enumerated() {
            if index < presignedURLs.count, uploadedPhotoIds.contains(presignedURLs[index].photoId) {
                let uploadedPhoto = UploadedLocalPhotoInfo(
                    id: assetId,
                    photoId: presignedURLs[index].photoId,
                    photoUrl: presignedURLs[index].photoUrl,
                    uploadedAt: Date()
                )
                photoRepository.saveRecord(uploadedPhoto)
            }
        }
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
