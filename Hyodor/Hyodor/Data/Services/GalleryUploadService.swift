//
//  GalleryUploadService.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import SwiftUI

// MARK: - 프로토콜 정의 (async/await)
protocol GalleryUploadServiceProtocol {
    func requestPresignedURLs(imageInfos: [ImageUploadRequestDTO]) async throws -> [PresignedURLResponseDTO]
    func uploadImageToS3(image: UIImage, presignedURL: PresignedURLResponseDTO) async throws
    func notifyUploadComplete(userId: String, uploadedPhotos: [UploadedPhotoInfoDTO]) async throws -> SyncResponseDTO
    func syncPhotos(userId: String) async throws -> SyncResponseDTO
}

// MARK: - 서비스 구현 (async/await)
class GalleryUploadService: GalleryUploadServiceProtocol {

    func requestPresignedURLs(imageInfos: [ImageUploadRequestDTO]) async throws -> [PresignedURLResponseDTO] {
        guard let url = URL(string: APIConstants.baseURL + APIConstants.Endpoints.galleryUploadInit) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let jsonData = try JSONEncoder().encode(imageInfos)
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let presignedURLs = try JSONDecoder().decode([PresignedURLResponseDTO].self, from: data)
        return presignedURLs
    }

    // 2. S3에 이미지 업로드
    func uploadImageToS3(image: UIImage, presignedURL: PresignedURLResponseDTO) async throws {
        guard let uploadURL = URL(string: presignedURL.uploadUrl) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "PUT"
        let contentType = presignedURL.uploadUrl.contains(".png") ? "image/png" : "image/jpeg"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        let imageData: Data?
        if contentType == "image/png" {
            imageData = image.pngData()
        } else {
            imageData = image.jpegData(compressionQuality: 0.9)
        }
        guard let data = imageData else {
            throw NSError(domain: "ImageEncoding", code: -1)
        }
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    // 3. 업로드 완료 알림
    func notifyUploadComplete(userId: String, uploadedPhotos: [UploadedPhotoInfoDTO]) async throws -> SyncResponseDTO {
        guard let url = URL(string: APIConstants.baseURL + APIConstants.Endpoints.galleryUploadComplete) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let requestBody = UploadCompleteRequestDTO(userId: userId, photos: uploadedPhotos)
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let uploadCompleteResponse = try JSONDecoder().decode(SyncResponseDTO.self, from: data)
        return uploadCompleteResponse
    }

    // 4. 사진 동기화 요청
    func syncPhotos(userId: String) async throws -> SyncResponseDTO {
        guard var components = URLComponents(string: APIConstants.baseURL + APIConstants.Endpoints.galleryAll) else {
            throw URLError(.badURL)
        }
        components.queryItems = [URLQueryItem(name: "userId", value: userId)]
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let syncResponse = try JSONDecoder().decode(SyncResponseDTO.self, from: data)
        return syncResponse
    }
}
