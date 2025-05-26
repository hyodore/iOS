//
//  SharedPhotoRepositoryImpl.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import Foundation

class SharedPhotoRepositoryImpl: SharedPhotoRepository {
    private let networkService: SharedPhotoNetworkService

    init(networkService: SharedPhotoNetworkService = SharedPhotoNetworkServiceImpl()) {
        self.networkService = networkService
    }

    func getAllPhotos(userId: String) async throws -> [SharedPhoto] {
        let response = try await networkService.getAllPhotos(userId: userId)
        return PhotoMapper.toDomainArray(response.photos)
    }

    func deletePhotos(userId: String, photoIds: [String]) async throws {
        try await networkService.deletePhotos(userId: userId, photoIds: photoIds)
    }
}

