//
//  SharedPhoto.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import Foundation

struct SharedPhoto: Identifiable {
    let photoId: String
    let familyId: String
    let photoUrl: String
    let uploadedBy: String
    let uploadedAt: Date
    let deleted: Bool
    let deletedAt: Date?

    var id: String { photoId }
    var imageURL: URL? { URL(string: photoUrl) }
}
