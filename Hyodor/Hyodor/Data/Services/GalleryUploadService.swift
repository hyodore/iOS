//
//  GalleryUploadService.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import SwiftUI
import Alamofire

protocol GalleryUploadServiceProtocol {
    func requestPresignedURLs(imageInfos: [ImageUploadRequestDTO]) async throws -> [PresignedURLResponseDTO]
    func uploadImageToS3(image: UIImage, presignedURL: PresignedURLResponseDTO) async throws
    func notifyUploadComplete(userId: String, uploadedPhotos: [UploadedPhotoInfoDTO]) async throws -> SyncResponseDTO
    func syncPhotos(userId: String) async throws -> SyncResponseDTO
}

class GalleryUploadService: GalleryUploadServiceProtocol {
    private let session: Session

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 120

        self.session = Session(configuration: configuration)
    }

    func requestPresignedURLs(imageInfos: [ImageUploadRequestDTO]) async throws -> [PresignedURLResponseDTO] {
        let url = APIConstants.baseURL + APIConstants.Endpoints.galleryUploadInit

        return try await session.request(
            url,
            method: .post,
            parameters: imageInfos,
            encoder: JSONParameterEncoder.default,
            headers: [
                "Content-Type": "application/json;charset=UTF-8"
            ]
        )
        .validate()
        .serializingDecodable([PresignedURLResponseDTO].self)
        .value
    }

    func uploadImageToS3(image: UIImage, presignedURL: PresignedURLResponseDTO) async throws {
        guard let uploadURL = URL(string: presignedURL.uploadUrl) else {
            throw AFError.invalidURL(url: presignedURL.uploadUrl)
        }

        let contentType = presignedURL.uploadUrl.contains(".png") ? "image/png" : "image/jpeg"
        let imageData: Data

        if contentType == "image/png" {
            guard let data = image.pngData() else {
                throw GalleryUploadError.imageEncodingFailed
            }
            imageData = data
        } else {
            guard let data = image.jpegData(compressionQuality: 0.9) else {
                throw GalleryUploadError.imageEncodingFailed
            }
            imageData = data
        }

        _ = try await session.upload(
            imageData,
            to: uploadURL,
            method: .put,
            headers: ["Content-Type": contentType]
        )
        .validate()
        .serializingData(emptyResponseCodes: [200, 204])
        .value
    }

    func notifyUploadComplete(userId: String, uploadedPhotos: [UploadedPhotoInfoDTO]) async throws -> SyncResponseDTO {
        let url = APIConstants.baseURL + APIConstants.Endpoints.galleryUploadComplete
        let requestBody = UploadCompleteRequestDTO(userId: userId, photos: uploadedPhotos)

        return try await session.request(
            url,
            method: .post,
            parameters: requestBody,
            encoder: JSONParameterEncoder.default,
            headers: [
                "Content-Type": "application/json;charset=UTF-8"
            ]
        )
        .validate()
        .serializingDecodable(SyncResponseDTO.self)
        .value
    }

    func syncPhotos(userId: String) async throws -> SyncResponseDTO {
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
        .serializingDecodable(SyncResponseDTO.self)
        .value
    }
}

// MARK: - Custom Errors

enum GalleryUploadError: LocalizedError {
    case imageEncodingFailed
    case invalidPresignedURL
    case uploadFailed(String)

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:
            return "이미지 인코딩에 실패했습니다."
        case .invalidPresignedURL:
            return "유효하지 않은 업로드 URL입니다."
        case .uploadFailed(let message):
            return "업로드 실패: \(message)"
        }
    }
}
