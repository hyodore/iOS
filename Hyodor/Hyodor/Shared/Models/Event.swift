//
//  Event.swift
//  Hyodor
//
//  Created by 김상준 on 4/30/25.
//

import Foundation

// MARK: - Model
struct Event: Codable, Identifiable {
    let id: UUID
    var title: String
    var date: Date
    var notes: String
}


// MARK: - UserDefaults 저장소
class EventStorage {
    private let userDefaults = UserDefaults.standard
    private let eventsKey = "events"

    func saveEvents(_ events: [Event]) {
        do {
            let data = try JSONEncoder().encode(events)
            userDefaults.set(data, forKey: eventsKey)
        } catch {
            print("Failed to save events: \(error)")
        }
    }

    func loadEvents() -> [Event] {
        guard let data = userDefaults.data(forKey: eventsKey) else { return [] }
        do {
            let events = try JSONDecoder().decode([Event].self, from: data)
            return events
        } catch {
            print("Failed to load events: \(error)")
            return []
        }
    }
}
