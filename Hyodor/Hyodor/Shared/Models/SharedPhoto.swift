//
//  SharedPhoto.swift
//  Hyodor
//
//  Created by 김상준 on 4/24/25.
//
import Foundation

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


// /api/gallery/all 응답
struct AllPhotosResponse: Codable {
    let photos: [SharedPhoto]
}


