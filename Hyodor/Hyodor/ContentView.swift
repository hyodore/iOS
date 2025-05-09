//
//  ContentView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
struct ContentView: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var homeViewModel = HomeViewModel(coordinator: HomeCoordinator())

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: homeViewModel, coordinator: homeViewModel.coordinator)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Firebase 초기화
        FirebaseApp.configure()

        // FCM 메시지 수신 대리자 설정
        Messaging.messaging().delegate = self

        // 푸시 알림 권한 요청
        requestNotificationAuthorization(application)

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
        completionHandler([.banner, .badge, .sound])  // 앱이 활성화된 동안에도 알림을 표시
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 알림 탭 후 행동 처리
        print("User tapped the notification")
        completionHandler()
    }
}

