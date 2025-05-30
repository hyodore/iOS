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
    let calendarVM = CalendarVM()

    var notifications: [NotificationData] = []
    var selectedSchedule: Schedule? = nil
    var selectedDate: Date = Date()

    private let getDisplayedSchedulesUseCase: GetDisplayedSchedulesUseCase
    private let getLatestNotificationsUseCase: GetLatestNotificationsUseCase
    private let deleteScheduleUseCase: DeleteScheduleUseCase
    private let notificationRepository: NotificationRepository
    private let getScheduleStatusUseCase: GetScheduleStatusUseCase

    var displayedEvents: [Schedule] {
        return getDisplayedSchedulesUseCase.execute()
    }

    init(
        coordinator: HomeCoordinator,
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
        notificationRepository: NotificationRepository = NotificationRepositoryImpl(),
        getScheduleStatusUseCase: GetScheduleStatusUseCase = GetScheduleStatusUseCaseImpl()
    ) {
        self.coordinator = coordinator
        self.getDisplayedSchedulesUseCase = getDisplayedSchedulesUseCase
        self.getLatestNotificationsUseCase = getLatestNotificationsUseCase
        self.deleteScheduleUseCase = deleteScheduleUseCase
        self.notificationRepository = notificationRepository
        self.getScheduleStatusUseCase = getScheduleStatusUseCase
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

    func getLatestNotifications(){
        notifications = getLatestNotificationsUseCase.execute()
    }

    func isToday(for event: Schedule) -> Bool {
           return getScheduleStatusUseCase.execute(for: event)
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
