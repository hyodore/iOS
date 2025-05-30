//
//  GetScheduleStatusUseCase.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import Foundation

protocol GetScheduleStatusUseCase {
    func execute(for schedule: Schedule) -> Bool
}

class GetScheduleStatusUseCaseImpl: GetScheduleStatusUseCase {
    func execute(for schedule: Schedule) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        return calendar.isDate(schedule.date, inSameDayAs: now)
    }
}

