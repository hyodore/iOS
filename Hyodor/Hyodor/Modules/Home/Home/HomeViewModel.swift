//
//  HomeViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import Observation
import Foundation

@Observable
class HomeViewModel {
    let coordinator: HomeCoordinator
    var selectedDate: Date = Date()
    private let eventStorage = EventStorage()
    var events: [Event] = []

    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
        self.events = eventStorage.loadEvents()
    }

    // 일정 추가
    func addEvent(title: String, date: Date, notes: String) {
        let event = Event(id: UUID(), title: title, date: date, notes: notes)
        events = events + [event] // 반드시 새로운 배열 할당!
        eventStorage.saveEvents(events)
        // 서버 업로드 필요시 여기에 추가
    }

    // 일정 삭제
    func removeEvent(_ event: Event) {
        events = events.filter { $0.id != event.id }
        eventStorage.saveEvents(events)
        // 서버 삭제 필요시 여기에 추가
    }

    // 필요시 강제 리로드
    func reloadEvents() {
        self.events = eventStorage.loadEvents()
    }

    // 버튼 액션
    func didTapCalendar() {
        coordinator.showCalendar()
    }
    func didTapSharedAlbum() {
        coordinator.showSharedAlbum()
    }
    func didTapAlert() {
        coordinator.showAlert()
    }
}
