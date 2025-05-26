//
//  AlertViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import SwiftUI

@Observable
class AlertViewModel {
    var notifications: [NotificationData] = []

    private let notificationRepository: NotificationRepository

    init(notificationRepository: NotificationRepository = NotificationRepositoryImpl()) {
        self.notificationRepository = notificationRepository
    }

    func loadNotifications() {
        notifications = notificationRepository.getNotifications()
    }

    func deleteNotification(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
        notificationRepository.saveNotifications(notifications)
    }
}
