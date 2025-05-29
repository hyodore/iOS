//
//  ScheduleNetworkService.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import Foundation

protocol ScheduleNetworkService {
    func uploadSchedule(_ schedule: Schedule, audioFileURL: URL?) async throws
    func deleteSchedule(_ scheduleId: UUID) async throws
}

class ScheduleNetworkServiceImpl: ScheduleNetworkService {
    func uploadSchedule(_ schedule: Schedule, audioFileURL: URL? = nil) async throws {

        guard let url = URL(string: APIConstants.baseURL + APIConstants.Endpoints.scheduleUpload) else {
            throw URLError(.badURL)
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        outputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let scheduleData: [String: Any] = [
            "scheduleId": schedule.id.uuidString,
            "userId": APIConstants.userId,
            "scheduleDesc": schedule.title,
            "scheduleDate": outputFormatter.string(from: schedule.date),
            "notes": schedule.notes ?? ""
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: scheduleData, options: []) else {
            throw URLError(.cannotParseResponse)
        }

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"data\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        body.append(jsonData)
        body.append("\r\n".data(using: .utf8)!)

        if let audioURL = audioFileURL {
            let filename = audioURL.lastPathComponent
            do {
                let fileData = try Data(contentsOf: audioURL)
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: audio/mp4\r\n\r\n".data(using: .utf8)!)
                body.append(fileData)
                body.append("\r\n".data(using: .utf8)!)
            } catch {
                throw URLError(.cannotLoadFromNetwork)
            }
        } else {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

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
