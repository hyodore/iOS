//
//  Appdelegate.swift
//  Hyodor
//
//  Created by 김상준 on 5/12/25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    private let fcmManager: FCMManager
    private let notificationService: NotificationService
    private let notificationParser: NotificationDataParser

    override init() {
        self.fcmManager = FCMManagerImpl()
        self.notificationService = NotificationServiceImpl()
        self.notificationParser = NotificationDataParserImpl()
        super.init()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        fcmManager.configure()
        fcmManager.setDelegate(self)
        UNUserNotificationCenter.current().delegate = self
        Task {
            await notificationService.requestAuthorization()
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(tokenParts)")
        fcmManager.setAPNSToken(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = fcmToken {
            print("FCM Token: \(fcmToken)")
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        handleNotification(userInfo: notification.request.content.userInfo)
        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotification(userInfo: response.notification.request.content.userInfo)
        print("User tapped the notification")
        completionHandler()
    }

    private func handleNotification(userInfo: [AnyHashable: Any]) {
        print(userInfo)

        if let notificationData = notificationParser.parseNotificationData(from: userInfo) {
            notificationService.saveNotification(notificationData)
        }
    }
}
