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
