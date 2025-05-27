//
//  FCMManager.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import Foundation
import FirebaseCore
import FirebaseMessaging

protocol FCMManager {
    func configure()
    func setDelegate(_ delegate: MessagingDelegate)
    func setAPNSToken(_ token: Data)
}

class FCMManagerImpl: FCMManager {
    func configure() {
        FirebaseApp.configure()
    }

    func setDelegate(_ delegate: MessagingDelegate) {
        Messaging.messaging().delegate = delegate
    }

    func setAPNSToken(_ token: Data) {
        Messaging.messaging().apnsToken = token
    }
}
