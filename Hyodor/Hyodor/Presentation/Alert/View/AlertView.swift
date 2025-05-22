//
//  AlertView.swift
//  Hyodor
//
//  Created by 김상준 on 4/28/25.
//

import SwiftUI
import WebKit

struct AlertView: View {
    @State private var notifications: [NotificationData] = []
    @State private var isLoading = false
    @State private var requestResult: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(notifications, id: \.receivedDate) { notification in
                        NavigationLink(destination: VideoPlayerView(videoUrl: notification.videoUrl)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(notification.title)
                                    .font(.headline)
                                Text(notification.body)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(notification.receivedDate.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .onDelete(perform: deleteNotification)
                }
                .onAppear(perform: loadNotifications)
                .onReceive(NotificationCenter.default.publisher(for: .newNotificationReceived)) { _ in
                    loadNotifications()
                }
            }
        }
    }

    private func loadNotifications() {
        if let savedNotifications = UserDefaults.standard.array(forKey: "notifications") as? [Data] {
            let decoder = JSONDecoder()
            notifications = savedNotifications.compactMap { data in
                try? decoder.decode(NotificationData.self, from: data)
            }
        }
    }

    private func deleteNotification(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
        let encoder = JSONEncoder()
        if let encodedData = try? notifications.map({ try encoder.encode($0) }) {
            UserDefaults.standard.set(encodedData, forKey: "notifications")
        }
    }
}
