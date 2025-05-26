//
//  ScheduleRepository.swift
//  Hyodor
//
//  Created by 김상준 on 5/26/25.
//

import Foundation

protocol ScheduleRepository {
    func getSchedules() -> [Schedule]
    func saveSchedules(_ schedules: [Schedule])
}
