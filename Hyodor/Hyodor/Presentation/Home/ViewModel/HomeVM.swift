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

    private let getDisplayedSchedulesUseCase: GetDisplayedSchedulesUseCase
    private let getLatestNotificationsUseCase: GetLatestNotificationsUseCase
    private let deleteScheduleUseCase: DeleteScheduleUseCase
    private let notificationRepository: NotificationRepository

    var displayedEvents: [Schedule] {
        return getDisplayedSchedulesUseCase.execute()
    }

    init(
        coordinator: HomeCoordinator,
        calendarVM: CalendarVM = CalendarVM(),
        getDisplayedSchedulesUseCase: GetDisplayedSchedulesUseCase = GetDisplayedSchedulesUseCaseImpl(
            scheduleRepository: ScheduleRepositoryImpl()
        ),
        getLatestNotificationsUseCase: GetLatestNotificationsUseCase = GetLatestNotificationsUseCaseImpl(
            notificationRepository: NotificationRepositoryImpl()
        ),
        deleteScheduleUseCase: DeleteScheduleUseCase = DeleteScheduleUseCaseImpl(
            scheduleRepository: ScheduleRepositoryImpl(),
            scheduleNetworkService: ScheduleNetworkServiceImpl()
        ),
        notificationRepository: NotificationRepository = NotificationRepositoryImpl()
    ) {
        self.coordinator = coordinator
        self.calendarVM = calendarVM
        self.getDisplayedSchedulesUseCase = getDisplayedSchedulesUseCase
        self.getLatestNotificationsUseCase = getLatestNotificationsUseCase
        self.deleteScheduleUseCase = deleteScheduleUseCase
        self.notificationRepository = notificationRepository
    }

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

    func loadNotifications() {
        notifications = notificationRepository.getNotifications()
    }

    func getLatestNotifications() -> [NotificationData] {
        return getLatestNotificationsUseCase.execute()
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
        do {
            try await deleteScheduleUseCase.execute(schedule)
            selectedSchedule = nil
            calendarVM.loadEvents()
        } catch {
            print("일정 삭제 실패: \(error.localizedDescription)")
        }
    }
}
