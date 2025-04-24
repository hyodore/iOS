//
//  SharedAlbumViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/24/25.
//
import Foundation
@Observable
class SharedAlbumViewModel {
    var photos: [SharedPhoto] = []
    var isLoading = false
    var errorMessage: String?

    let baseURL = "http://107.21.85.186:8080"
    let userId = "user123"

    func syncPhotos() async {
        isLoading = true
        defer { isLoading = false }

        guard var components = URLComponents(string: "\(baseURL)/api/gallery/all") else {
            errorMessage = "잘못된 URL입니다"
            return
        }
        components.queryItems = [URLQueryItem(name: "userId", value: userId)]
        guard let url = components.url else {
            errorMessage = "URL 생성 실패"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                errorMessage = "서버 오류가 발생했습니다"
                return
            }
            let decoded = try JSONDecoder().decode(AllPhotosResponse.self, from: data)
            self.photos = decoded.photos
                .filter { !$0.deleted }
                .sorted { $0.uploadedAt > $1.uploadedAt }

            print("photos.count = \(photos.count)")
            for photo in photos {
                print("photoId: \(photo.photoId), url: \(photo.photoUrl)")
            }
        } catch {
            errorMessage = "네트워크/파싱 오류: \(error.localizedDescription)"
        }
    }
}
