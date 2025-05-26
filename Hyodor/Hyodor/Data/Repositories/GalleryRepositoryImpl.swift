//
//  GalleryRepositoryImpl.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import SwiftUI

class GalleryRepositoryImpl: GalleryRepository {
    private let galleryUploadService: GalleryUploadServiceProtocol

    init(galleryUploadService: GalleryUploadServiceProtocol = GalleryUploadService()) {
        self.galleryUploadService = galleryUploadService
    }

    func requestPresignedURLs(imageInfos: [ImageUploadRequestDTO]) async throws -> [PresignedURLResponseDTO] {
        return try await galleryUploadService.requestPresignedURLs(imageInfos: imageInfos)
    }

    func uploadImageToS3(image: UIImage, presignedURL: PresignedURLResponseDTO) async throws {
        try await galleryUploadService.uploadImageToS3(image: image, presignedURL: presignedURL)
    }

    func notifyUploadComplete(userId: String, uploadedPhotos: [UploadedPhotoInfoDTO]) async throws -> SyncResponseDTO {
        return try await galleryUploadService.notifyUploadComplete(userId: userId, uploadedPhotos: uploadedPhotos)
    }

    func syncPhotos(userId: String) async throws -> SyncResponseDTO {
        return try await galleryUploadService.syncPhotos(userId: userId)
    }
}
