//
//  GetLatestNotificationsUseCase.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import Foundation

protocol GetLatestNotificationsUseCase {
    func execute() -> [NotificationData]
}

class GetLatestNotificationsUseCaseImpl: GetLatestNotificationsUseCase {
    private let notificationRepository: NotificationRepository

    init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }

    func execute() -> [NotificationData] {
        let notifications = notificationRepository.getNotifications()
        return Array(notifications.prefix(4))
    }
}
