//
//  UploadedPhotoManager.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import Foundation

class PhotoStorageService {
    private let userDefaults = UserDefaults.standard
    private let uploadedPhotosKey = "uploadedPhotos"

    func getAllUploadedPhotos() -> [UploadedLocalPhotoInfo] {
        guard let savedData = userDefaults.array(forKey: uploadedPhotosKey) as? [[String: Any]] else {
            return []
        }

        return savedData.compactMap { UploadedLocalPhotoInfo.fromDictionary($0) }
    }

    func isPhotoUploaded(assetId: String) -> Bool {
        return getAllUploadedPhotos().contains { $0.id == assetId }
    }

    func saveUploadedPhoto(_ photo: UploadedLocalPhotoInfo) {
        var savedData = userDefaults.array(forKey: uploadedPhotosKey) as? [[String: Any]] ?? []

        if let index = savedData.firstIndex(where: { ($0["id"] as? String) == photo.id }) {
            savedData[index] = photo.toDictionary()
        } else {
            savedData.append(photo.toDictionary())
        }

        userDefaults.set(savedData, forKey: uploadedPhotosKey)
    }

    func saveUploadedPhotos(_ photos: [UploadedLocalPhotoInfo]) {
        for photo in photos {
            saveUploadedPhoto(photo)
        }
    }

    func removeUploadedPhoto(assetId: String) {
        var savedData = userDefaults.array(forKey: uploadedPhotosKey) as? [[String: Any]] ?? []
        savedData.removeAll { ($0["id"] as? String) == assetId }
        userDefaults.set(savedData, forKey: uploadedPhotosKey)
    }

    func clearAllUploadedPhotos() {
        userDefaults.removeObject(forKey: uploadedPhotosKey)
    }
}
