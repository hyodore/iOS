//
//  NotificationRepositoryImpl.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import Foundation

class NotificationRepositoryImpl: NotificationRepository {
    private let userDefaults: UserDefaults
    private let notificationsKey = "notifications"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getNotifications() -> [NotificationData] {
        guard let savedNotifications = userDefaults.array(forKey: notificationsKey) as? [Data] else {
            return []
        }

        let decoder = JSONDecoder()
        return savedNotifications.compactMap { data in
            try? decoder.decode(NotificationData.self, from: data)
        }.sorted(by: { $0.receivedDate > $1.receivedDate })
    }

    func saveNotifications(_ notifications: [NotificationData]) {
        let encoder = JSONEncoder()
        let encodedData = notifications.compactMap { notification in
            try? encoder.encode(notification)
        }
        userDefaults.set(encodedData, forKey: notificationsKey)
    }
}
