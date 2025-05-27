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

    private let getSchedulesUseCase: GetSchedulesUseCase
    private let addScheduleUseCase: AddScheduleUseCase
    private let deleteScheduleUseCase: DeleteScheduleUseCase

    init(
        getSchedulesUseCase: GetSchedulesUseCase = GetSchedulesUseCaseImpl(
            scheduleRepository: ScheduleRepositoryImpl()
        ),
        addScheduleUseCase: AddScheduleUseCase = AddScheduleUseCaseImpl(
            scheduleRepository: ScheduleRepositoryImpl(),
            scheduleNetworkService: ScheduleNetworkServiceImpl()
        ),
        deleteScheduleUseCase: DeleteScheduleUseCase = DeleteScheduleUseCaseImpl(
            scheduleRepository: ScheduleRepositoryImpl(),
            scheduleNetworkService: ScheduleNetworkServiceImpl()
        )
    ) {
        self.getSchedulesUseCase = getSchedulesUseCase
        self.addScheduleUseCase = addScheduleUseCase
        self.deleteScheduleUseCase = deleteScheduleUseCase
        loadEvents()
    }

    func loadEvents() {
        events = getSchedulesUseCase.execute()
    }

    func addEvent(title: String, date: Date, notes: String) async {

        
        do {
            try await addScheduleUseCase.execute(title: title, date: date, notes: notes)
            loadEvents()
        } catch {
            print("일정 추가 실패: \(error.localizedDescription)")
        }
    }

    func removeEvent(_ event: Schedule) async {
        do {
            try await deleteScheduleUseCase.execute(event)
            loadEvents()
        } catch {
            print("일정 삭제 실패: \(error.localizedDescription)")
        }
    }
}
