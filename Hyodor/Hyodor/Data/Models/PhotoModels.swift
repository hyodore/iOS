//
//  Model.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import Foundation
import Photos

// MARK: - 로컬 사진 선택 모델 (사진첩에서 사용)
struct PhotoAssetModel: Identifiable {
    let asset: PHAsset
    var isSelected: Bool = false
    var isUploaded: Bool = false

    var id: String {
        asset.localIdentifier
    }
}

// MARK: - 공유 앨범의 사진 모델 (전체 조회/동기화 등에서 사용)
struct SharedPhoto: Identifiable, Codable {
    var id: String { photoId }
    let photoId: String
    let familyId: String
    let photoUrl: String
    let uploadedBy: String
    let uploadedAt: String
    let deleted: Bool
    let deletedAt: String?

    var imageURL: URL? {
           URL(string: photoUrl)
       }
}

