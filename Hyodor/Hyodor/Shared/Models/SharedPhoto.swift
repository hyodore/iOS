//
//  SharedPhoto.swift
//  Hyodor
//
//  Created by 김상준 on 4/24/25.
//

import Foundation
// 공유 앨범 사진 모델
struct SharedPhoto: Identifiable, Codable {
    let id: String
    let photoId: String
    let photoUrl: String
    let uploadedBy: String
    let uploadedAt: String
    var deleted: Bool
    var deletedAt: String?

    // 이미지 URL 반환
    var imageURL: URL? {
        return URL(string: photoUrl)
    }
}

// 공유 앨범 모델
class SharedAlbumModel: ObservableObject {
    @Published var photos: [SharedPhoto] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let uploadService: GalleryUploadServiceProtocol

    init(uploadService: GalleryUploadServiceProtocol = GalleryUploadService()) {
        self.uploadService = uploadService
    }

    // 공유 앨범 사진 로드
    func loadSharedPhotos() {
        isLoading = true

        // 여기서는 업로드 완료 응답에서 받은 사진 목록을 사용
        // 실제로는 별도의 API 호출이 필요할 수 있음
        // 예시 코드이므로 모의 데이터 사용
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            // 모의 데이터
            self.photos = [
                SharedPhoto(
                    id: "1",
                    photoId: "photo-1",
                    photoUrl: "https://picsum.photos/id/1/500/500",
                    uploadedBy: "user123",
                    uploadedAt: "2025-04-15T12:00:00",
                    deleted: false,
                    deletedAt: nil
                ),
                SharedPhoto(
                    id: "2",
                    photoId: "photo-2",
                    photoUrl: "https://picsum.photos/id/2/500/500",
                    uploadedBy: "user123",
                    uploadedAt: "2025-04-15T12:05:00",
                    deleted: false,
                    deletedAt: nil
                )
            ]
        }
    }

    // 업로드 완료 후 새 사진 추가
    func addNewPhotos(from response: UploadCompleteResponse) {
        let newPhotos = response.newPhoto.map { photo in
            SharedPhoto(
                id: photo.photoId,
                photoId: photo.photoId,
                photoUrl: photo.photoUrl,
                uploadedBy: photo.uploadedBy,
                uploadedAt: photo.uploadedAt,
                deleted: photo.deleted,
                deletedAt: photo.deletedAt
            )
        }

        // 중복 제거하며 추가
        let existingIds = Set(photos.map { $0.photoId })
        let uniqueNewPhotos = newPhotos.filter { !existingIds.contains($0.photoId) }

        // 삭제된 사진 처리
        let deletedPhotoIds = Set(response.deletedPhoto.map { $0.photoId })

        // 기존 사진 중 삭제되지 않은 것 + 새 사진
        photos = photos.filter { !deletedPhotoIds.contains($0.photoId) } + uniqueNewPhotos
    }
}

