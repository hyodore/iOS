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
    private let uploadedPhotoManager = UploadedPhotoManager()

    let baseURL = "http://107.21.85.186:8080"
    let userId = "user123"


    // 조회 API 호출
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

    // 삭제 API 호출
    func deletePhotos(photoIds: [String]) async {
        guard !photoIds.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: "\(baseURL)/api/gallery/delete") else {
            errorMessage = "잘못된 URL"
            return
        }
        let body = [
            "userId": userId,
            "photoIds": photoIds
        ] as [String : Any]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                errorMessage = "삭제 실패: 서버 오류"
                return
            }
            // 1. 서버 동기화
            await syncPhotos()

            // 2. 업로드 정보도 삭제!
            // photoIds는 서버의 photoId(UUID)임.
            // UploadedPhotoManager는 assetId(PHAsset.localIdentifier)로 관리함.
            // → photoId와 assetId를 매핑해서 assetId를 찾아야 함.

            let uploadedPhotos = uploadedPhotoManager.getAllUploadedPhotos()
            let toRemoveAssetIds = uploadedPhotos
                .filter { photoIds.contains($0.photoId) }
                .map { $0.id }

            for assetId in toRemoveAssetIds {
                uploadedPhotoManager.removeUploadedPhoto(assetId: assetId)
            }
        } catch {
            errorMessage = "삭제 실패: \(error.localizedDescription)"
        }
    }
}
