//
//  MockUseCases.swift
//  HyodorTests
//
//  Created by 김상준 on 6/12/25.
//

import Foundation
@testable import Hyodor

// 테스트용 커스텀 에러 정의
enum TestError: Error, LocalizedError {
    case general
    var errorDescription: String? { "테스트 에러가 발생했습니다." }
}

// GetAllPhotosUseCase의 Mock 객체
class MockGetAllPhotosUseCase: GetAllPhotosUseCase {
    // 이 변수를 조작하여 성공/실패 경우를 시뮬레이션
    var result: Result<[SharedPhoto], Error> = .success([])

    func execute(userId: String) async throws -> [SharedPhoto] {
        switch result {
        case .success(let photos):
            return photos
        case .failure(let error):
            throw error
        }
    }
}

// DeletePhotosUseCase의 Mock 객체
class MockDeletePhotosUseCase: DeletePhotosUseCase {
    // 이 변수를 조작하여 에러 발생을 시뮬레이션
    var errorToThrow: Error?
    // 이 UseCase가 어떤 photoId로 호출되었는지 기록
    var calledWithPhotoIds: [String]?

    func execute(userId: String, photoIds: [String]) async throws {
        self.calledWithPhotoIds = photoIds
        if let error = errorToThrow {
            throw error
        }
        // 성공 시 아무것도 하지 않음 (void 반환)
    }
}
