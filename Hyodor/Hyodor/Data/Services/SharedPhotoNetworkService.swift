//
//  SharedPhotoNetworkService.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import Foundation
import Alamofire

protocol SharedPhotoNetworkService {
    func getAllPhotos(userId: String) async throws -> AllSyncResponseDTO
    func deletePhotos(userId: String, photoIds: [String]) async throws
}

class SharedPhotoNetworkServiceImpl: SharedPhotoNetworkService {
    private let session: Session

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        self.session = Session(configuration: configuration)
    }

    func getAllPhotos(userId: String) async throws -> AllSyncResponseDTO {
        let url = APIConstants.baseURL + APIConstants.Endpoints.galleryAll

        return try await session.request(
            url,
            method: .get,
            parameters: ["userId": userId],
            headers: [
                "Accept": "application/json"
            ]
        )
        .validate()
        .serializingDecodable(AllSyncResponseDTO.self)
        .value
    }

    func deletePhotos(userId: String, photoIds: [String]) async throws {
        let url = APIConstants.baseURL + APIConstants.Endpoints.galleryDelete

        let requestBody = PhotoDeleteRequestDTO(userId: userId, photoIds: photoIds)

        _ = try await session.request(
            url,
            method: .post,
            parameters: requestBody,
            encoder: JSONParameterEncoder.default,
            headers: [
                "Content-Type": "application/json;charset=UTF-8"
            ]
        )
        .validate()
        .serializingData(emptyResponseCodes: [200, 204])
        .value
    }
}

// MARK: - Custom Errors

enum SharedPhotoNetworkError: LocalizedError {
    case invalidUserId
    case photoNotFound
    case deletionFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidUserId:
            return "유효하지 않은 사용자 ID입니다."
        case .photoNotFound:
            return "삭제할 사진을 찾을 수 없습니다."
        case .deletionFailed(let message):
            return "사진 삭제 실패: \(message)"
        }
    }
}
