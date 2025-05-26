//
//  ScheduleRepositoryImpl.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import Foundation

class ScheduleRepositoryImpl: ScheduleRepository {
    private let scheduleStorage: ScheduleStorageService

    init(scheduleStorage: ScheduleStorageService = ScheduleStorageService()) {
        self.scheduleStorage = scheduleStorage
    }

    func getSchedules() -> [Schedule] {
        return scheduleStorage.loadEvents()
    }

    func saveSchedules(_ schedules: [Schedule]) {
        scheduleStorage.saveEvents(schedules)
    }
}
