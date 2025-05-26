//
//  GetAllPhotosUseCase.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import Foundation

protocol GetAllPhotosUseCase {
    func execute(userId: String) async throws -> [SharedPhoto]
}

class GetAllPhotosUseCaseImpl: GetAllPhotosUseCase {
    private let sharedPhotoRepository: SharedPhotoRepository

    init(sharedPhotoRepository: SharedPhotoRepository) {
        self.sharedPhotoRepository = sharedPhotoRepository
    }

    func execute(userId: String) async throws -> [SharedPhoto] {
        return try await sharedPhotoRepository.getAllPhotos(userId: userId)
    }
}
