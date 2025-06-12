//
//  PhotoRepository.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import SwiftUI

protocol LocalPhotoRecordRepository {
    func fetchAllRecords() -> [UploadedLocalPhotoInfo]
    func checkIsUploaded(assetId: String) -> Bool
    func saveRecord(_ photo: UploadedLocalPhotoInfo)
    func removeRecord(assetId: String)
}
