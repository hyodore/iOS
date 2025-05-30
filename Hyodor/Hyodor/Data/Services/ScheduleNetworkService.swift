//
//  ScheduleNetworkService.swift
//  Hyodor
//
//  Created by 김상준 on 5/27/25.
//

import Foundation
import Alamofire

protocol ScheduleNetworkService {
    func uploadSchedule(_ schedule: Schedule, audioFileURL: URL?) async throws
    func deleteSchedule(_ scheduleId: UUID) async throws
}

class ScheduleNetworkServiceImpl: ScheduleNetworkService {
    private let session: Session

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 300

        self.session = Session(configuration: configuration)
    }

    func uploadSchedule(_ schedule: Schedule, audioFileURL: URL? = nil) async throws {
        let url = APIConstants.baseURL + APIConstants.Endpoints.scheduleUpload

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
            throw ScheduleNetworkError.dataEncodingFailed
        }

        _ = try await session.upload(
            multipartFormData: { formData in
                formData.append(
                    jsonData,
                    withName: "data",
                    mimeType: "application/json"
                )

                if let audioURL = audioFileURL {
                    formData.append(
                        audioURL,
                        withName: "file",
                        fileName: audioURL.lastPathComponent,
                        mimeType: "audio/mp4"
                    )
                } else {
                    formData.append(
                        Data(),
                        withName: "file",
                        fileName: "",
                        mimeType: "application/octet-stream"
                    )
                }
            },
            to: url,
            method: .post
        )
        .validate()
        .serializingData(emptyResponseCodes: [200, 204])
        .value
    }

    func deleteSchedule(_ scheduleId: UUID) async throws {
        let url = APIConstants.baseURL + APIConstants.Endpoints.scheduleDelete
        let body = ScheduleDeleteRequestDTO(scheduleId: scheduleId.uuidString)

        _ = try await session.request(
            url,
            method: .post,
            parameters: body,
            encoder: JSONParameterEncoder.default,
            headers: [
                "Content-Type": "application/json;charset=UTF-8"
            ]
        )
        .validate()
        .serializingData(emptyResponseCodes: [200, 204])
        .value
    }
}

// MARK: - Custom Errors

enum ScheduleNetworkError: LocalizedError {
    case dataEncodingFailed
    case audioFileNotFound
    case uploadFailed(String)

    var errorDescription: String? {
        switch self {
        case .dataEncodingFailed:
            return "일정 데이터 인코딩에 실패했습니다."
        case .audioFileNotFound:
            return "오디오 파일을 찾을 수 없습니다."
        case .uploadFailed(let message):
            return "일정 업로드 실패: \(message)"
        }
    }
}
