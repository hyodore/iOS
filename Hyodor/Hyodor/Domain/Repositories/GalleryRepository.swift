//
//  GalleryRepository.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import SwiftUI

protocol GalleryRepository {
    func requestPresignedURLs(imageInfos: [ImageUploadRequestDTO]) async throws -> [PresignedURLResponseDTO]
    func uploadImageToS3(image: UIImage, presignedURL: PresignedURLResponseDTO) async throws
    func notifyUploadComplete(userId: String, uploadedPhotos: [UploadedPhotoInfoDTO]) async throws -> SyncResponseDTO
    func syncPhotos(userId: String) async throws -> SyncResponseDTO
}
