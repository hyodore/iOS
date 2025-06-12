//
//  PhotoRepositoryImpl.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import SwiftUI

class LocalPhotoRecordRepositoryImpl: LocalPhotoRecordRepository
 {
    private let photoStorageService: PhotoStorageService

    init(photoStorageService: PhotoStorageService = PhotoStorageService()) {
        self.photoStorageService = photoStorageService
    }

    func fetchAllRecords() -> [UploadedLocalPhotoInfo] {
        return photoStorageService.getAllUploadedPhotos()
    }

    func checkIsUploaded(assetId: String) -> Bool {
        return photoStorageService.isPhotoUploaded(assetId: assetId)
    }

    func saveRecord(_ photo: UploadedLocalPhotoInfo) {
        photoStorageService.saveUploadedPhoto(photo)
    }

    func removeRecord(assetId: String) {
        photoStorageService.removeUploadedPhoto(assetId: assetId)
    }
}
