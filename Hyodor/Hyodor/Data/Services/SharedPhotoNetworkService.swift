//
//  SharedPhotoNetworkService.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import Foundation

protocol SharedPhotoNetworkService {
    func getAllPhotos(userId: String) async throws -> AllSyncResponseDTO
    func deletePhotos(userId: String, photoIds: [String]) async throws
}

class SharedPhotoNetworkServiceImpl: SharedPhotoNetworkService {
    func getAllPhotos(userId: String) async throws -> AllSyncResponseDTO {
        guard var components = URLComponents(string: APIConstants.baseURL + APIConstants.Endpoints.galleryAll) else {
            throw URLError(.badURL)
        }
        components.queryItems = [URLQueryItem(name: "userId", value: userId)]
        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(AllSyncResponseDTO.self, from: data)
    }

    func deletePhotos(userId: String, photoIds: [String]) async throws {
        guard let url = URL(string: APIConstants.baseURL + APIConstants.Endpoints.galleryDelete) else {
            throw URLError(.badURL)
        }

        let body = [
            "userId": userId,
            "photoIds": photoIds
        ] as [String : Any]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
