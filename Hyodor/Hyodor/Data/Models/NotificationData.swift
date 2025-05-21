//
//  NotificationData.swift
//  Hyodor
//
//  Created by 김상준 on 5/22/25.
//

import Foundation

struct NotificationData: Codable {
    let title: String
    let body: String
    let videoUrl: String
    let userId: String
    let receivedDate: Date
}
