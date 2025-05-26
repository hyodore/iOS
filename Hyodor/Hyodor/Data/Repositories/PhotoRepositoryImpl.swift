//
//  PhotoRepositoryImpl.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import SwiftUI

class PhotoRepositoryImpl: PhotoRepository {
    private let photoStorageService: PhotoStorageService

    init(photoStorageService: PhotoStorageService = PhotoStorageService()) {
        self.photoStorageService = photoStorageService
    }

    func getAllUploadedPhotos() -> [UploadedLocalPhotoInfo] {
        return photoStorageService.getAllUploadedPhotos()
    }

    func isPhotoUploaded(assetId: String) -> Bool {
        return photoStorageService.isPhotoUploaded(assetId: assetId)
    }

    func saveUploadedPhoto(_ photo: UploadedLocalPhotoInfo) {
        photoStorageService.saveUploadedPhoto(photo)
    }

    func removeUploadedPhoto(assetId: String) {
        photoStorageService.removeUploadedPhoto(assetId: assetId)
    }
}
