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

// NotificationCenter에 사용할 알림 이름 정의
extension Notification.Name {
    static let newNotificationReceived = Notification.Name("newNotificationReceived")
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure() // Firebase 초기화
        Messaging.messaging().delegate = self // FCM 메시지 수신 대리자 설정
        requestNotificationAuthorization(application) // 푸시 알림 권한 요청
        return true
    }

    // 알림 권한 요청 메서드
    func requestNotificationAuthorization(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }

    // APNs 토큰 등록
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(tokenParts)")

        // FCM 토큰 등록
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // MARK: MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = fcmToken {
            print("FCM Token: \(fcmToken)")
        }
    }

    // MARK: UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 앱이 포그라운드에 있을 때 알림 수신 시 데이터 저장
        let userInfo = notification.request.content.userInfo
        saveNotificationData(from: userInfo)
        // NotificationCenter를 통해 알림 수신 이벤트 브로드캐스트
        NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
        completionHandler([.banner, .badge, .sound]) // 앱이 활성화된 동안에도 알림을 표시
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 알림 탭 후 행동 처리
        let userInfo = response.notification.request.content.userInfo
        saveNotificationData(from: userInfo)
        // NotificationCenter를 통해 알림 수신 이벤트 브로드캐스트
        NotificationCenter.default.post(name: .newNotificationReceived, object: nil)
        print("User tapped the notification")
        completionHandler()
    }

    // 알림 데이터를 로컬에 저장하는 메서드
    private func saveNotificationData(from userInfo: [AnyHashable: Any]) {
        // notification 페이로드에서 title, body 추출
        let title = userInfo["title"] as? String ?? "알림"
        let body = userInfo["body"] as? String ?? "새로운 메시지가 도착했습니다."

        // data 페이로드에서 videoUrl, userId 추출
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any] {
            // notification 페이로드가 있는 경우
            let title = alert["title"] as? String ?? "알림"
            let body = alert["body"] as? String ?? "새로운 메시지가 도착했습니다."
            let videoUrl = userInfo["videoUrl"] as? String ?? ""
            let userId = userInfo["userId"] as? String ?? ""

            let notificationData = NotificationData(
                title: title,
                body: body,
                videoUrl: videoUrl,
                userId: userId,
                receivedDate: Date()
            )
            saveToUserDefaults(notificationData)
        } else {
            // data 페이로드만 있는 경우 (백그라운드 메시지 등)
            let videoUrl = userInfo["videoUrl"] as? String ?? ""
            let userId = userInfo["userId"] as? String ?? ""

            let notificationData = NotificationData(
                title: title,
                body: body,
                videoUrl: videoUrl,
                userId: userId,
                receivedDate: Date()
            )
            saveToUserDefaults(notificationData)
        }
    }

    // UserDefaults에 저장
    private func saveToUserDefaults(_ data: NotificationData) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            if var notifications = UserDefaults.standard.array(forKey: "notifications") as? [Data] {
                notifications.insert(encodedData, at: 0) // 최신 알림을 리스트 상단에 추가
                UserDefaults.standard.set(notifications, forKey: "notifications")
            } else {
                UserDefaults.standard.set([encodedData], forKey: "notifications")
            }
            print("Notification data saved to UserDefaults")
        } catch {
            print("Failed to save notification data: \(error)")
        }
    }
}
