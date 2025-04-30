//
//  CalendarViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/30/25.
//

import SwiftUI

@Observable
class CalendarViewModel {
    var events: [Event] = []
    var selectedDate: Date = Date()

    private let baseURL = "http://107.21.85.186:8080"
    private let userId: String = "user123"
    private let eventStorage = EventStorage()

    init() {
            events = eventStorage.loadEvents()
        }

    // 일정 추가
    func addEvent(title: String, date: Date, color: Color, notes: String) {
        let event = Event(id: UUID(), title: title, date: date, notes: notes)
        uploadSchedule(event: event) { [weak self] success in
            guard let self = self else { return }
            if success {
                // 서버 업로드 성공 시 로컬에 추가
                self.events.append(event)
                self.eventStorage.saveEvents(self.events)
            } else {
                // 실패 시 사용자에게 알림 등 처리
                print("서버 업로드 실패")
            }
        }
    }


    // 일정 삭제
    func removeEvent(_ event: Event) {
        deleteSchedule(scheduleId: event.id.uuidString) { [weak self] success in
            guard let self = self else { return }
            if success {
                // 서버 삭제 성공 시 로컬에서 삭제
                self.events.removeAll { $0.id == event.id }
                self.eventStorage.saveEvents(self.events)
            } else {
                // 실패 시 사용자에게 알림 등 처리
                print("서버 삭제 실패")
            }
        }
    }
    // 서버 업로드: 성공 시 true, 실패 시 false 반환
    func uploadSchedule(event: Event, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/schedule/upload") else { completion(false); return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")

        let isoFormatter = ISO8601DateFormatter()
        let scheduleDate = isoFormatter.string(from: event.date)

        let body = ScheduleUploadRequest(
            scheduleId: event.id.uuidString,
            userId: userId,
            scheduleDesc: event.title,
            scheduleDate: scheduleDate
        )

        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
        } catch {
            print("Encoding error: \(error)")
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("업로드 실패: \(error)")
                completion(false)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }

    // 서버 삭제: 성공 시 true, 실패 시 false 반환
    func deleteSchedule(scheduleId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/schedule/delete") else { completion(false); return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")

        let body = ScheduleDeleteRequest(scheduleId: scheduleId)
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
        } catch {
            print("Encoding error: \(error)")
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("삭제 실패: \(error)")
                completion(false)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(false)
                return
            }
            completion(true)
        }.resume()
    }

}
