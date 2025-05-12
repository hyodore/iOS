//
//  APIConstants.swift
//  Hyodor
//
//  Created by 김상준 on 5/12/25.
//

import Foundation

struct APIConstants {
    static let baseURL = "http://54.172.64.98:8080"
    static let userId = "user123"

    struct Endpoints {
        // Gallery 관련 엔드포인트
        static let galleryUploadInit = "/api/gallery/upload/init"
        static let galleryUploadComplete = "/api/gallery/upload/complete"
        static let galleryAll = "/api/gallery/all"

        // Schedule 관련 엔드포인트
        static let scheduleUpload = "/api/schedule/upload"
        static let scheduleDelete = "/api/schedule/delete"
    }
}
