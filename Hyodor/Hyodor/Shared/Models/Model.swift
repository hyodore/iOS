//
//  Model.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

// MARK: - 모델
import Foundation
import Photos

// API 응답 모델
struct PresignedURLResponse: Codable {
    let photoId: String
    let uploadUrl: String
    let photoUrl: String
}

struct UploadCompleteRequest: Codable {
    let userId: String
    let photos: [UploadedPhotoInfo]

    struct UploadedPhotoInfo: Codable {
        let photoId: String
        let photoUrl: String
        let uploadAt: String
    }
}

struct UploadCompleteResponse: Codable {
    let syncedAt: String
    let newPhoto: [PhotoInfo]
    let deletedPhoto: [PhotoInfo]

    struct PhotoInfo: Codable {
        let photoId: String
        let familyId: String
        let photoUrl: String
        let uploadedBy: String
        let uploadedAt: String
        let deleted: Bool
        let deletedAt: String?
    }
}

// 사진 모델
struct PhotoAssetModel: Identifiable {
    let asset: PHAsset
    var isSelected: Bool = false
    var isUploaded: Bool = false

    var id: String {
        asset.localIdentifier
    }
}

// 업로드된 사진 정보를 저장하는 모델
struct UploadedPhotoInfo: Codable, Identifiable {
    let id: String // PHAsset의 localIdentifier
    let photoId: String // 서버에서 할당한 UUID
    let photoUrl: String // S3 URL
    let uploadedAt: Date

    // UserDefaults 저장을 위한 Dictionary 변환
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "photoId": photoId,
            "photoUrl": photoUrl,
            "uploadedAt": uploadedAt.timeIntervalSince1970
        ]
    }

    // Dictionary에서 모델 생성
    static func fromDictionary(_ dict: [String: Any]) -> UploadedPhotoInfo? {
        guard let id = dict["id"] as? String,
              let photoId = dict["photoId"] as? String,
              let photoUrl = dict["photoUrl"] as? String,
              let timestamp = dict["uploadedAt"] as? TimeInterval else {
            return nil
        }

        return UploadedPhotoInfo(
            id: id,
            photoId: photoId,
            photoUrl: photoUrl,
            uploadedAt: Date(timeIntervalSince1970: timestamp)
        )
    }
}

