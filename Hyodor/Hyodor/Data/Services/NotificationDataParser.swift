//
//  NotificationDataParser.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import Foundation

protocol NotificationDataParser {
    func parseNotificationData(from userInfo: [AnyHashable: Any]) -> NotificationData?
}

class NotificationDataParserImpl: NotificationDataParser {
    func parseNotificationData(from userInfo: [AnyHashable: Any]) -> NotificationData? {
        guard let videoUrl = userInfo["videoUrl"] as? String, !videoUrl.isEmpty else {
            print("videoUrl이 없는 FCM은 저장하지 않습니다.")
            return nil
        }

        var title = "알림"
        var body = "새로운 메시지가 도착했습니다."
        let userId = userInfo["userId"] as? String ?? ""

        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any] {
            title = alert["title"] as? String ?? title
            body = alert["body"] as? String ?? body
        } else {
            title = userInfo["title"] as? String ?? title
            body = userInfo["body"] as? String ?? body
        }

        return NotificationData(
            title: title,
            body: body,
            videoUrl: videoUrl,
            userId: userId,
            receivedDate: Date()
        )
    }
}
