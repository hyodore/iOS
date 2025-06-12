//
//  GetScheduleUseCase.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import Foundation

protocol GetSchedulesUseCase {
    func execute() -> [Schedule]
}

class GetSchedulesUseCaseImpl: GetSchedulesUseCase {
    private let scheduleRepository: ScheduleRepository

    init(scheduleRepository: ScheduleRepository) {
        self.scheduleRepository = scheduleRepository
    }

    func execute() -> [Schedule] {
        return scheduleRepository.getSchedules()
    }
}

