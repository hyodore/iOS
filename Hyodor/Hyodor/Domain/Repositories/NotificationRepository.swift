//
//  NotificationRepository.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import Foundation

protocol NotificationRepository {
    func getNotifications() -> [NotificationData]
    func saveNotifications(_ notifications: [NotificationData])
}
