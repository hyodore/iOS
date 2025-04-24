//
//  Model.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

// MARK: - 모델
import Foundation
import Photos

// MARK: - Presigned URL 발급 응답
struct PresignedURLResponse: Codable {
    let photoId: String        // 사진 UUID
    let uploadUrl: String      // S3 Presigned PUT URL
    let photoUrl: String       // 정적 URL (업로드 후 접근용)
}

// MARK: - 업로드 완료 요청
struct UploadCompleteRequest: Codable {
    let userId: String
    let photos: [UploadedPhotoInfo]

    struct UploadedPhotoInfo: Codable {
        let photoId: String    // Presigned URL 요청에서 받은 UUID
        let photoUrl: String   // S3에 업로드된 사진 URL
        let uploadAt: String   // 클라이언트에서 업로드 완료된 시간(ISO 8601)
    }
}

// MARK: - 업로드 완료 응답 & 동기화 응답
struct UploadCompleteResponse: Codable {
    let syncedAt: String
    let newPhoto: [PhotoInfo]
    let deletedPhoto: [PhotoInfo]

    struct PhotoInfo: Codable, Identifiable {
        let photoId: String
        let familyId: String
        let photoUrl: String
        let uploadedBy: String
        let uploadedAt: String
        let deleted: Bool
        let deletedAt: String?
        var id: String { photoId }
    }
}

// /api/gallery/sync 응답
struct SyncResponse: Codable {
    let syncedAt: String
    let newPhoto: [SharedPhoto]
    let deletedPhoto: [SharedPhoto]
}

// MARK: - 로컬 사진 선택 모델 (사진첩에서 사용)
struct PhotoAssetModel: Identifiable {
    let asset: PHAsset
    var isSelected: Bool = false
    var isUploaded: Bool = false

    var id: String {
        asset.localIdentifier
    }
}

// MARK: - 업로드된 사진 로컬 저장 모델 (UserDefaults 등에서 사용)
struct UploadedLocalPhotoInfo: Codable, Identifiable {
    let id: String         // PHAsset의 localIdentifier
    let photoId: String    // 서버에서 할당한 UUID
    let photoUrl: String   // S3 URL
    let uploadedAt: Date

    func toDictionary() -> [String: Any] {
        [
            "id": id,
            "photoId": photoId,
            "photoUrl": photoUrl,
            "uploadedAt": uploadedAt.timeIntervalSince1970
        ]
    }

    static func fromDictionary(_ dict: [String: Any]) -> UploadedLocalPhotoInfo? {
        guard let id = dict["id"] as? String,
              let photoId = dict["photoId"] as? String,
              let photoUrl = dict["photoUrl"] as? String,
              let timestamp = dict["uploadedAt"] as? TimeInterval else {
            return nil
        }
        return UploadedLocalPhotoInfo(
            id: id,
            photoId: photoId,
            photoUrl: photoUrl,
            uploadedAt: Date(timeIntervalSince1970: timestamp)
        )
    }
}
