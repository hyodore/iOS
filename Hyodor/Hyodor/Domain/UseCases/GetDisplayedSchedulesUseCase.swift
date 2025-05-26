//
//  GetDisplayedSchedulesUseCase.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import Foundation

protocol GetDisplayedSchedulesUseCase {
    func execute() -> [Schedule]
}

class GetDisplayedSchedulesUseCaseImpl: GetDisplayedSchedulesUseCase {
    private let scheduleRepository: ScheduleRepository

    init(scheduleRepository: ScheduleRepository) {
        self.scheduleRepository = scheduleRepository
    }

    func execute() -> [Schedule] {
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let events = scheduleRepository.getSchedules()

        let todayUpcoming = events.filter {
            calendar.isDate($0.date, inSameDayAs: now) && $0.date >= now
        }.sorted { $0.date < $1.date }

        let todayPast = events.filter {
            calendar.isDate($0.date, inSameDayAs: now) && $0.date < now
        }.sorted { $0.date < $1.date }

        let future = events.filter {
            $0.date >= tomorrow
        }.sorted { $0.date < $1.date }

        let past = events.filter {
            $0.date < today
        }.sorted { $0.date > $1.date }

        return Array((todayUpcoming + todayPast + future + past).prefix(4))
    }
}
