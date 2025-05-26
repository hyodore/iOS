//
//  PhotoRepository.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import SwiftUI

protocol PhotoRepository {
    func getAllUploadedPhotos() -> [UploadedLocalPhotoInfo]
    func isPhotoUploaded(assetId: String) -> Bool
    func saveUploadedPhoto(_ photo: UploadedLocalPhotoInfo)
    func removeUploadedPhoto(assetId: String)
}
