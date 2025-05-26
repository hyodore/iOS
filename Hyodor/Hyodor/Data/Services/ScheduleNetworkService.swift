//
//  ScheduleNetworkService.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import Foundation

protocol ScheduleNetworkService {
    func uploadSchedule(_ schedule: Schedule) async throws
    func deleteSchedule(_ scheduleId: UUID) async throws
}

class ScheduleNetworkServiceImpl: ScheduleNetworkService {
    func uploadSchedule(_ schedule: Schedule) async throws {
        guard let url = URL(string: APIConstants.baseURL + APIConstants.Endpoints.scheduleUpload) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")

        let isoFormatter = ISO8601DateFormatter()
        let scheduleDate = isoFormatter.string(from: schedule.date)
        let body = ScheduleUploadRequestDTO(
            scheduleId: schedule.id.uuidString,
            userId: APIConstants.userId,
            scheduleDesc: schedule.title,
            scheduleDate: scheduleDate
        )

        let jsonData = try JSONEncoder().encode(body)
        request.httpBody = jsonData

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    func deleteSchedule(_ scheduleId: UUID) async throws {
        guard let url = URL(string: APIConstants.baseURL + APIConstants.Endpoints.scheduleDelete) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")

        let body = ScheduleDeleteRequestDTO(scheduleId: scheduleId.uuidString)
        let jsonData = try JSONEncoder().encode(body)
        request.httpBody = jsonData

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
