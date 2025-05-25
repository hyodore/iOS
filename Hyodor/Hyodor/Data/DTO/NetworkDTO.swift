//
//  NetworkModels.swift
//  Hyodor
//
//  Created by 김상준 on 4/27/25.
//

import Foundation

/// Presigned URL 발급 요청 (이미지 업로드 초기화)
struct ImageUploadRequestDTO: Codable {
    let fileName: String
    let contentType: String
}

/// Presigned URL 발급 응답 (S3 업로드 URL 제공)
struct PresignedURLResponseDTO: Codable {
    let photoId: String
    let uploadUrl: String
    let photoUrl: String
}

/// 업로드 완료 알림 요청 (서버에 업로드 완료 통보)
struct UploadCompleteRequestDTO: Codable {
    let userId: String
    let photos: [UploadedPhotoInfoDTO]
}

/// 업로드된 사진 정보 (업로드 완료 시 전송하는 사진 데이터)
struct UploadedPhotoInfoDTO: Codable {
    let photoId: String
    let photoUrl: String
    let uploadAt: String
}

/// 동기화/업로드 완료 응답 (서버 상태 변경 후 응답)
struct SyncResponseDTO: Codable {
    let syncedAt: String
    let newPhoto: [PhotoInfoDTO]
    let deletedPhoto: [PhotoInfoDTO]
}

/// 사진 정보 DTO (서버의 사진 메타데이터)
struct PhotoInfoDTO: Codable {
    let photoId: String
    let familyId: String
    let photoUrl: String
    let uploadedBy: String
    let uploadedAt: String
    let deleted: Bool
    let deletedAt: String?
}

/// 전체 사진 조회 응답 (갤러리 전체 사진 목록)
struct AllSyncResponseDTO: Codable {
    let photos: [SharedPhoto]
}

/// 사진 삭제 요청 (선택한 사진들 삭제)
struct PhotoDeleteRequestDTO: Codable {
    let userId: String
    let photoIds: [String]
}

/// 일정 업로드 요청 (새 일정 서버 저장)
struct ScheduleUploadRequestDTO: Codable {
    let scheduleId: String
    let userId: String
    let scheduleDesc: String
    let scheduleDate: String
}

/// 일정 삭제 요청 (기존 일정 서버 삭제)
struct ScheduleDeleteRequestDTO: Codable {
    let scheduleId: String
}
