//
//  HomeViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import Foundation

@Observable
class HomeVM {
    let coordinator: HomeCoordinator
    let calendarVM: CalendarVM
    var notifications: [NotificationData] = []
    var selectedSchedule: Schedule? = nil

    var selectedDate: Date = Date()

    var displayedEvents: [Schedule] {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let events = calendarVM.events

        // 1. 오늘 아직 하지 않은 일 (오늘이고, 현재 시간 이후)
        let todayUpcoming = events.filter {
            calendar.isDate($0.date, inSameDayAs: now) && $0.date >= now
        }.sorted { $0.date < $1.date }

        // 2. 오늘 이미 지난 일 (오늘이고, 현재 시간 이전)
        let todayPast = events.filter {
            calendar.isDate($0.date, inSameDayAs: now) && $0.date < now
        }.sorted { $0.date < $1.date }

        // 3. 내일부터 미래 일정 (내일 이후, 오름차순)
        let future = events.filter {
            $0.date >= tomorrow
        }.sorted { $0.date < $1.date }

        // 4. 가장 최근에 완료한 일정 (오늘 이전, 내림차순)
        let past = events.filter {
            $0.date < today
        }.sorted { $0.date > $1.date }

        return Array((todayUpcoming + todayPast + future + past).prefix(4))
    }

    init(coordinator: HomeCoordinator, calendarVM: CalendarVM) {
        self.coordinator = coordinator
        self.calendarVM = calendarVM
    }

    // MARK: - Lifecycle Methods

    func onAppear() {
        loadNotifications()
    }

    func onNotificationReceived() {
        loadNotifications()
    }

    // MARK: - Button Actions

    func didTapCalendar() {
        coordinator.showCalendar()
    }

    func didTapSharedAlbum() {
        coordinator.showSharedAlbum()
    }

    func didTapAlert() {
        coordinator.showAlert()
    }

    func didSelectSchedule(_ schedule: Schedule) {
        selectedSchedule = schedule
    }

    func didSelectNotification(_ notification: NotificationData) {
        coordinator.path.append(HomeCoordinator.HomeRoute.AlertDetail(notification))
    }

    func dismissScheduleDetail() {
        selectedSchedule = nil
    }

    // MARK: - Data Methods

    func loadNotifications() {
        if let savedNotifications = UserDefaults.standard.array(forKey: "notifications") as? [Data] {
            let decoder = JSONDecoder()
            let loadedNotifications = savedNotifications.compactMap { data in
                try? decoder.decode(NotificationData.self, from: data)
            }
            notifications = loadedNotifications.sorted(by: { $0.receivedDate > $1.receivedDate })
        } else {
            notifications = []
        }
    }

    func getLatestNotifications() -> [NotificationData] {
        return Array(notifications.prefix(4))
    }

    func getScheduleStatus(for event: Schedule) -> (isPast: Bool, isToday: Bool) {
        let calendar = Calendar.current
        let now = Date()
        let isToday = calendar.isDate(event.date, inSameDayAs: now)
        let isPast: Bool = {
            if isToday {
                return event.date < now
            } else {
                return event.date < calendar.startOfDay(for: now)
            }
        }()

        return (isPast: isPast, isToday: isToday)
    }

    func deleteSchedule(_ schedule: Schedule) async {
        await calendarVM.removeEvent(schedule)
        selectedSchedule = nil
    }
}
