//
//  SharedAlbumViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/24/25.
//
import Foundation
import SwiftUICore

@Observable
class SharedAlbumViewModel {
    var photos: [SharedPhoto] = []  // 공유 앨범의 사진 목록
    var isLoading = false
    var errorMessage: String?
    private let uploadedPhotoManager = PhotoStorageService() // 업로드된 사진 정보 관리 매니저

    // 서버에서 전체 사진 목록을 동기화
    func syncPhotos() async {
        isLoading = true
        defer { isLoading = false } // 메서드 종료시 로딩 상태 해제

        guard var components = URLComponents(string: APIConstants.baseURL + APIConstants.Endpoints.galleryAll) else {
            errorMessage = "잘못된 URL입니다"
            return
        }
        components.queryItems = [URLQueryItem(name: "userId", value: APIConstants.userId)]
        guard let url = components.url else {
            errorMessage = "URL 생성 실패"
            return
        }

        // 2. GET 요청 설정
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            // 3. 네트워크 요청 실행
            let (data, response) = try await URLSession.shared.data(for: request)
            // 4. 응답 검증: HTTP 상태 코드가 200~299인지 확인
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                errorMessage = "서버 오류가 발생했습니다"
                return
            }
            // 5. JSON 데이터를 SharedPhoto 배열로 디코딩
            let decoded = try JSONDecoder().decode(AllSyncResponseDTO.self, from: data)

            // 6. 삭제되지 않은 사진만 필터링하고, 최신순으로 정렬
            self.photos = decoded.photos
                .filter { !$0.deleted }
                .sorted { $0.uploadedAt > $1.uploadedAt }
        } catch {
            errorMessage = "네트워크/파싱 오류: \(error.localizedDescription)"
        }
    }

    // 서버에서 사진을 삭제하고 로컬 상태를 동기화하는 메서드
    // - Parameter photoIds: 삭제할 사진의 서버 photoId 목록
    func deletePhotos(photoIds: [String]) async {
        // 1. photoIds가 비어있으면 아무 작업도 하지 않음
        guard !photoIds.isEmpty else { return }
        // 2. 로딩 상태 시작
        isLoading = true
        // 메서드 종료 시 로딩 상태 해제
        defer { isLoading = false }
        guard let url = URL(string: APIConstants.baseURL + APIConstants.Endpoints.galleryDelete) else {
            errorMessage = "잘못된 URL"
            return
        }
        // 4. POST 요청 바디 생성: userId와 photoIds 포함
        let body = [
            "userId": APIConstants.userId,
            "photoIds": photoIds
        ] as [String : Any]
        // 5. POST 요청 설정
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")

        do {
            // 6. 요청 바디를 JSON으로 직렬화
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            // 7. 네트워크 요청 실행
            let (_, response) = try await URLSession.shared.data(for: request)
            // 8. 응답 검증: HTTP 상태 코드가 200~299인지 확인
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                errorMessage = "삭제 실패: 서버 오류"
                return
            }
            // 9. 서버 사진 목록 동기화
            await syncPhotos()

            // 10. 로컬 업로드 정보 삭제
            // - 서버의 photoId(UUID)와 로컬의 assetId(PHAsset.localIdentifier)를 매핑
            // - UploadedPhotoManager에서 해당 assetId를 찾아 제거
            let uploadedPhotos = uploadedPhotoManager.getAllUploadedPhotos()
            let toRemoveAssetIds = uploadedPhotos
                .filter { photoIds.contains($0.photoId) }
                .map { $0.id }

            for assetId in toRemoveAssetIds {
                uploadedPhotoManager.removeUploadedPhoto(assetId: assetId)
            }
        } catch {
            // 11. 에러 처리: 네트워크 또는 JSON 직렬화 에러
            errorMessage = "삭제 실패: \(error.localizedDescription)"
        }
    }
}

// 1. 환경키 및 확장
private struct SharedAlbumViewModelKey: EnvironmentKey {
    static let defaultValue: SharedAlbumViewModel = SharedAlbumViewModel()
}

extension EnvironmentValues {
    var sharedAlbumViewModel: SharedAlbumViewModel {
        get { self[SharedAlbumViewModelKey.self] }
        set { self[SharedAlbumViewModelKey.self] = newValue }
    }
}
