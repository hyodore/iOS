//
//  SharedPhotoRepository.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import Foundation

protocol SharedPhotoRepository {
    func getAllPhotos(userId: String) async throws -> [SharedPhoto]
    func deletePhotos(userId: String, photoIds: [String]) async throws
}

