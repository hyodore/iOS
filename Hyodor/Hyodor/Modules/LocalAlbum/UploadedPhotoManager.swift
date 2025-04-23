//
//  UploadedPhotoManager.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import Foundation

// 업로드된 사진 정보를 관리하는 서비스
class UploadedPhotoManager {
    private let userDefaults = UserDefaults.standard
    private let uploadedPhotosKey = "uploadedPhotos"

    // 모든 업로드된 사진 정보 가져오기
    func getAllUploadedPhotos() -> [UploadedPhotoInfo] {
        guard let savedData = userDefaults.array(forKey: uploadedPhotosKey) as? [[String: Any]] else {
            return []
        }

        return savedData.compactMap { UploadedPhotoInfo.fromDictionary($0) }
    }

    // 특정 사진이 업로드되었는지 확인
    func isPhotoUploaded(assetId: String) -> Bool {
        return getAllUploadedPhotos().contains { $0.id == assetId }
    }

    // 업로드된 사진 정보 저장
    func saveUploadedPhoto(_ photo: UploadedPhotoInfo) {
        var savedData = userDefaults.array(forKey: uploadedPhotosKey) as? [[String: Any]] ?? []

        // 이미 있는 경우 업데이트
        if let index = savedData.firstIndex(where: { ($0["id"] as? String) == photo.id }) {
            savedData[index] = photo.toDictionary()
        } else {
            savedData.append(photo.toDictionary())
        }

        userDefaults.set(savedData, forKey: uploadedPhotosKey)
    }

    // 여러 업로드된 사진 정보 저장
    func saveUploadedPhotos(_ photos: [UploadedPhotoInfo]) {
        for photo in photos {
            saveUploadedPhoto(photo)
        }
    }

    // 업로드된 사진 정보 삭제
    func removeUploadedPhoto(assetId: String) {
        var savedData = userDefaults.array(forKey: uploadedPhotosKey) as? [[String: Any]] ?? []
        savedData.removeAll { ($0["id"] as? String) == assetId }
        userDefaults.set(savedData, forKey: uploadedPhotosKey)
    }

    // 모든 업로드된 사진 정보 삭제
    func clearAllUploadedPhotos() {
        userDefaults.removeObject(forKey: uploadedPhotosKey)
    }
}
