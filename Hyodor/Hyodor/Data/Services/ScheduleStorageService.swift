//
//  ScheduleStorage.swift
//  Hyodor
//
//  Created by 김상준 on 5/10/25.
//

import Foundation

class ScheduleStorageService {
    private let userDefaults = UserDefaults.standard
    private let schedulesKey = "schedules"

    func saveEvents(_ events: [Schedule]) {
        do {
            let data = try JSONEncoder().encode(events)
            userDefaults.set(data, forKey: schedulesKey)
        } catch {
            print("스케줄 저장 실패: \(error)")
        }
    }

    func loadEvents() -> [Schedule] {
        guard let data = userDefaults.data(forKey: schedulesKey) else { return [] }
        do {
            let events = try JSONDecoder().decode([Schedule].self, from: data)
            return events
        } catch {
            print("스케줄 로드 실패: \(error)")
            return []
        }
    }
}
