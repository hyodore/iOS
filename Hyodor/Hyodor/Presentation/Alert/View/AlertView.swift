//
//  AlertView.swift
//  Hyodor
//
//  Created by 김상준 on 4/28/25.
//

import SwiftUI

struct AlertView: View {
    @State private var viewModel = AlertViewModel()

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.notifications, id: \.receivedDate) { notification in
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
                    .onDelete(perform: viewModel.deleteNotification)
                }
                .onAppear {
                    viewModel.loadNotifications()
                }
                .onReceive(NotificationCenter.default.publisher(for: .newNotificationReceived)) { _ in
                    viewModel.loadNotifications()
                }
            }
        }
    }
}

