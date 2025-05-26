//
//  UploadedLocalPhotoInfo.swift
//  Hyodor
//
//  Created by 김상준 on 4/27/25.
//

import Foundation

struct UploadedLocalPhotoInfo: Codable, Identifiable {
    let id: String
    let photoId: String
    let photoUrl: String
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
