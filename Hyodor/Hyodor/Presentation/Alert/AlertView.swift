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
                    .onDelete(perform: deleteNotification) // 스와이프 삭제 기능 추가
                }
                .onAppear(perform: loadNotifications)
                .onReceive(NotificationCenter.default.publisher(for: .newNotificationReceived)) { _ in
                    // 새 알림 수신 시 리스트 업데이트
                    loadNotifications()
                    print("새 알림 수신, 리스트 업데이트 완료")
                }

                Button(action: {
                    sendTestPushRequest()
                }) {
                    Text(isLoading ? "요청 중..." : "테스트 푸시 알림 요청")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isLoading ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isLoading)
                .padding(.horizontal)

                if !requestResult.isEmpty {
                    Text(requestResult)
                        .font(.subheadline)
                        .foregroundColor(requestResult.contains("성공") ? .green : .red)
                        .padding(.top, 8)
                }
            }
        }
    }

    private func loadNotifications() {
        if let savedNotifications = UserDefaults.standard.array(forKey: "notifications") as? [Data] {
            let decoder = JSONDecoder()
            notifications = savedNotifications.compactMap { data in
                do {
                    return try decoder.decode(NotificationData.self, from: data)
                } catch {
                    print("Failed to decode notification data: \(error)")
                    return nil
                }
            }
            // 로드된 알림 데이터를 콘솔에 출력
            print("로드된 알림 데이터:")
            for (index, notification) in notifications.enumerated() {
                print("알림 \(index + 1):")
                print("  제목: \(notification.title)")
                print("  내용: \(notification.body)")
                print("  비디오 URL: \(notification.videoUrl)")
                print("  사용자 ID: \(notification.userId)")
                print("  수신 날짜: \(notification.receivedDate)")
            }
            if notifications.isEmpty {
                print("저장된 알림 데이터가 없습니다.")
            }
        } else {
            print("UserDefaults에 저장된 알림 데이터가 없습니다.")
        }
    }

    private func deleteNotification(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
        // UserDefaults에 저장된 데이터도 업데이트
        let encoder = JSONEncoder()
        do {
            let encodedData = try notifications.map { try encoder.encode($0) }
            UserDefaults.standard.set(encodedData, forKey: "notifications")
            print("삭제 후 UserDefaults 업데이트 완료")
        } catch {
            print("UserDefaults 업데이트 실패: \(error)")
        }
    }

    private func sendTestPushRequest() {
        isLoading = true
        requestResult = ""

        guard let url = URL(string: "\(APIConstants.baseURL)\(APIConstants.testEndpoint)") else {
            requestResult = "오류: 유효하지 않은 URL입니다."
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let eventName = String(APIConstants.testEndpoint.split(separator: "/").last ?? "test")
        let body: [String: Any] = ["fcmToken": APIConstants.fcmToken, "event": eventName]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            print("JSON 직렬화 오류: \(error)")
            requestResult = "오류: JSON 데이터 생성 실패"
            isLoading = false
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    requestResult = "오류: 요청 전송 실패 - \(error.localizedDescription)"
                    return
                }

                if let response = response as? HTTPURLResponse {
                    if (200...299).contains(response.statusCode) {
                        requestResult = "성공: 서버 응답 코드 \(response.statusCode)"
                    } else {
                        requestResult = "오류: 서버 응답 코드 \(response.statusCode)"
                    }
                } else {
                    requestResult = "오류: 서버 응답을 확인할 수 없습니다."
                }
            }
        }
        task.resume()
    }
}

struct VideoPlayerView: View {
    let videoUrl: String

    var body: some View {
        if let url = URL(string: videoUrl), videoUrl.lowercased().hasPrefix("http://") || videoUrl.lowercased().hasPrefix("https://") {
            WebView(url: url)
                .navigationTitle("이벤트 영상")
                .onAppear {
                    print("Loading video URL: \(videoUrl)")
                }
        } else {
            Text("유효하지 않은 영상 URL입니다. URL은 http:// 또는 https://로 시작해야 합니다.")
                .foregroundColor(.red)
                .navigationTitle("오류")
                .onAppear {
                    print("Invalid video URL: \(videoUrl)")
                }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
