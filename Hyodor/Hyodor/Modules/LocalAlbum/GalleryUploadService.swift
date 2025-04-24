//
//  GalleryUploadService.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import Foundation
import UIKit

// MARK: - 프로토콜 정의 (async/await)
protocol GalleryUploadServiceProtocol {
    func requestPresignedURLs(imageInfos: [[String: String]]) async throws -> [PresignedURLResponse]
    func uploadImageToS3(image: UIImage, presignedURL: PresignedURLResponse) async throws
    func notifyUploadComplete(userId: String, uploadedPhotos: [UploadCompleteRequest.UploadedPhotoInfo]) async throws -> UploadCompleteResponse
    func syncPhotos(userId: String) async throws -> SyncResponse
}

// MARK: - 서비스 구현 (async/await)
class GalleryUploadService: GalleryUploadServiceProtocol {
    private let baseURL = "http://107.21.85.186:8080"

    // 1. Presigned URL 발급 요청
    func requestPresignedURLs(imageInfos: [[String: String]]) async throws -> [PresignedURLResponse] {
        guard let url = URL(string: "\(baseURL)/api/gallery/upload/init") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let jsonData = try JSONSerialization.data(withJSONObject: imageInfos, options: [])
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let presignedURLs = try JSONDecoder().decode([PresignedURLResponse].self, from: data)
        return presignedURLs
    }

    // 2. S3에 이미지 업로드
    func uploadImageToS3(image: UIImage, presignedURL: PresignedURLResponse) async throws {
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
    func notifyUploadComplete(userId: String, uploadedPhotos: [UploadCompleteRequest.UploadedPhotoInfo]) async throws -> UploadCompleteResponse {
        guard let url = URL(string: "\(baseURL)/api/gallery/upload/complete") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let requestBody = UploadCompleteRequest(userId: userId, photos: uploadedPhotos)
        let jsonData = try JSONEncoder().encode(requestBody)
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let uploadCompleteResponse = try JSONDecoder().decode(UploadCompleteResponse.self, from: data)
        return uploadCompleteResponse
    }

    // 4. 사진 동기화 요청
    func syncPhotos(userId: String) async throws -> SyncResponse {
        guard var components = URLComponents(string: "\(baseURL)/api/gallery/all") else {
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
        let syncResponse = try JSONDecoder().decode(SyncResponse.self, from: data)
        return syncResponse
    }
}
