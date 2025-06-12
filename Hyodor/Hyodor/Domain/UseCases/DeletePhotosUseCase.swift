//
//  DeletePhotosUseCase.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import Foundation

protocol DeletePhotosUseCase {
    func execute(userId: String, photoIds: [String]) async throws
}

class DeletePhotosUseCaseImpl: DeletePhotosUseCase {
    private let sharedPhotoRepository: SharedPhotoRepository
    private let photoRepository: LocalPhotoRecordRepository


    init(
        sharedPhotoRepository: SharedPhotoRepository,
        photoRepository: LocalPhotoRecordRepository

    ) {
        self.sharedPhotoRepository = sharedPhotoRepository
        self.photoRepository = photoRepository
    }

    func execute(userId: String, photoIds: [String]) async throws {
        try await sharedPhotoRepository.deletePhotos(userId: userId, photoIds: photoIds)

        let uploadedPhotos = photoRepository.fetchAllRecords()
        let toRemoveAssetIds = uploadedPhotos
            .filter { photoIds.contains($0.photoId) }
            .map { $0.id }

        for assetId in toRemoveAssetIds {
            photoRepository.removeRecord(assetId: assetId)
        }
    }
}

