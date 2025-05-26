//
//  AddScheduleUseCase.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import Foundation

protocol AddScheduleUseCase {
    func execute(title: String, date: Date, notes: String) async throws
}

class AddScheduleUseCaseImpl: AddScheduleUseCase {
    private let scheduleRepository: ScheduleRepository
    private let scheduleNetworkService: ScheduleNetworkService

    init(
        scheduleRepository: ScheduleRepository,
        scheduleNetworkService: ScheduleNetworkService
    ) {
        self.scheduleRepository = scheduleRepository
        self.scheduleNetworkService = scheduleNetworkService
    }

    func execute(title: String, date: Date, notes: String) async throws {
        let schedule = Schedule(id: UUID(), title: title, date: date, notes: notes)

        try await scheduleNetworkService.uploadSchedule(schedule)

        var schedules = scheduleRepository.getSchedules()
        schedules.append(schedule)
        scheduleRepository.saveSchedules(schedules)
    }
}
