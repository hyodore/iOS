//
//  NotificationService.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import SwiftUI

protocol NotificationService {
    func requestAuthorization() async -> Bool
    func registerForRemoteNotifications()
    func saveNotification(_ data: NotificationData)
}

class NotificationServiceImpl: NotificationService {
    private let notificationRepository: NotificationRepository

    init(notificationRepository: NotificationRepository = NotificationRepositoryImpl()) {
        self.notificationRepository = notificationRepository
    }

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            return granted
        } catch {
            print("알림 권한 요청 실패: \(error)")
            return false
        }
    }

    func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func saveNotification(_ data: NotificationData) {
        var notifications = notificationRepository.getNotifications()
        notifications.insert(data, at: 0)
        notificationRepository.saveNotifications(notifications)

        NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
    }
}
