//
//  PhotoModels.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import Foundation
import Photos

struct PhotoAssetModel: Identifiable {
    let asset: PHAsset
    var isSelected: Bool = false
    var isUploaded: Bool = false

    var id: String {
        asset.localIdentifier
    }
}
