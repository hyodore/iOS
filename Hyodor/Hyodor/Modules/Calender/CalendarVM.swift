//
//  CalendarViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/30/25.
//

import Foundation

@Observable
class CalendarVM {
    var events: [Schedule] = []
    var selectedDate: Date = Date()
    private let eventStorage = ScheduleStorage()

    init() {
        events = eventStorage.loadEvents()
    }

    // 일정 추가 (서버 업로드 성공시 -> 로컬 데이터 저장)
    func addEvent(title: String, date: Date, notes: String) async {
        let event = Schedule(id: UUID(), title: title, date: date, notes: notes)
        do {
            let success = try await uploadSchedule(event: event)
            if success {
                self.events.append(event)
                self.eventStorage.saveEvents(self.events)
            } else {
                print("서버 업로드 실패")
            }
        } catch {
            print("업로드 실패: \(error.localizedDescription)")
        }
    }

    // 일정 삭제 (서버 데이터 삭제 성공시 -> 로컬 데이터 삭제)
    func removeEvent(_ event: Schedule) async {
        do {
            let success = try await deleteSchedule(scheduleId: event.id.uuidString)
            if success {
                self.events.removeAll { $0.id == event.id }
                self.eventStorage.saveEvents(self.events)
            } else {
                print("서버 삭제 실패")
            }
        } catch {
            print("삭제 실패: \(error.localizedDescription)")
        }
    }

    // 서버 업로드: 성공 시 true, 실패 시 false return (async/await 패턴)
    func uploadSchedule(event: Schedule) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/api/schedule/upload") else {
            return false
        }
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

        let jsonData = try JSONEncoder().encode(body)
        request.httpBody = jsonData

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        return true
    }

    // 서버 삭제: 성공 시 true, 실패 시 false 반환 (async/await 패턴)
    func deleteSchedule(scheduleId: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/api/schedule/delete") else {
            return false
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let body = ScheduleDeleteRequest(scheduleId: scheduleId)

        let jsonData = try JSONEncoder().encode(body)
        request.httpBody = jsonData

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        return true
    }

}
