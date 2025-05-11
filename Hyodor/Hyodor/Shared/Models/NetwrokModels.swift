//
//  NetwrokModels.swift
//  Hyodor
//
//  Created by 김상준 on 4/27/25.
//

import Foundation

import Foundation

let baseURL = "http://44.203.156.146:8080"
let userId  = "user123"

// MARK: Presigned URL 발급 응답
struct PresignedURLResponse: Codable {
    let photoId: String        // 사진 UUID
    let uploadUrl: String      // S3 Presigned PUT URL
    let photoUrl: String       // 정적 URL (업로드 후 접근용)
}

// MARK: 업로드 완료 요청
struct UploadCompleteRequest: Codable {
    let userId: String
    let photos: [UploadedPhotoInfo]

    struct UploadedPhotoInfo: Codable {
        let photoId: String    // Presigned URL 요청에서 받은 UUID
        let photoUrl: String   // S3에 업로드된 사진 URL
        let uploadAt: String   // 클라이언트에서 업로드 완료된 시간(ISO 8601)
    }
}

// MARK: 업로드 완료 응답 & 동기화 응답
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

// MARK: /api/gallery/sync 응답
struct SyncResponse: Codable {
    let syncedAt: String
    let newPhoto: [SharedPhoto]
    let deletedPhoto: [SharedPhoto]
}

// MARK: /api/gallery/all
struct AllSyncResponse: Codable {
    let photos: [SharedPhoto]
}

//MARK: /api/schedule/upload
struct ScheduleUploadRequest: Codable {
    let scheduleId: String
    let userId: String
    let scheduleDesc: String
    let scheduleDate: String
}
// MARK: /api/schedule/delete
struct ScheduleDeleteRequest: Codable {
    let scheduleId: String
}
