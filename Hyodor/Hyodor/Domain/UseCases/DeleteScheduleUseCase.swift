//
//  DeleteScheduleUseCase.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import Foundation

protocol DeleteScheduleUseCase {
    func execute(_ schedule: Schedule) async throws
}

class DeleteScheduleUseCaseImpl: DeleteScheduleUseCase {
    private let scheduleRepository: ScheduleRepository
    private let scheduleNetworkService: ScheduleNetworkService

    init(
        scheduleRepository: ScheduleRepository,
        scheduleNetworkService: ScheduleNetworkService
    ) {
        self.scheduleRepository = scheduleRepository
        self.scheduleNetworkService = scheduleNetworkService
    }

    func execute(_ schedule: Schedule) async throws {
        try await scheduleNetworkService.deleteSchedule(schedule.id)
        var schedules = scheduleRepository.getSchedules()
        schedules.removeAll { $0.id == schedule.id }
        scheduleRepository.saveSchedules(schedules)
    }
}
