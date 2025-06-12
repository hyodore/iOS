//
//  SharedAlbumViewModelTests.swift
//  HyodorTests
//
//  Created by 김상준 on 6/12/25.
//

import XCTest
@testable import Hyodor

@MainActor
final class SharedAlbumViewModelTests: XCTestCase {

    var viewModel: SharedAlbumVM!
    var mockGetAllPhotosUseCase: MockGetAllPhotosUseCase!
    var mockDeletePhotosUseCase: MockDeletePhotosUseCase!

    // 각 테스트가 실행되기 전에 호출되는 설정 메소드
    override func setUp() {
        super.setUp()
        // Given: 모든 테스트는 새로운 Mock 객체와 ViewModel 인스턴스로 시작
        mockGetAllPhotosUseCase = MockGetAllPhotosUseCase()
        mockDeletePhotosUseCase = MockDeletePhotosUseCase()
        viewModel = SharedAlbumVM(
            getAllPhotosUseCase: mockGetAllPhotosUseCase,
            deletePhotosUseCase: mockDeletePhotosUseCase
        )
    }

    // 각 테스트가 끝난 후에 호출되는 정리 메소드
    override func tearDown() {
        viewModel = nil
        mockGetAllPhotosUseCase = nil
        mockDeletePhotosUseCase = nil
        super.tearDown()
    }

    // MARK: - syncPhotos() Tests

    func testSyncPhotos_Success() async {
        // Given: UseCase가 성공적으로 사진 2개를 반환하도록 설정
        let photos = [
            SharedPhoto(photoId: "1", familyId: "f1", photoUrl: "", uploadedBy: "", uploadedAt: Date(), deleted: false, deletedAt: nil),
            SharedPhoto(photoId: "2", familyId: "f1", photoUrl: "", uploadedBy: "", uploadedAt: Date().addingTimeInterval(-100), deleted: false, deletedAt: nil)
        ]
        mockGetAllPhotosUseCase.result = .success(photos)

        // When: 사진 동기화 실행
        await viewModel.syncPhotos()

        // Then: 결과 검증
        XCTAssertFalse(viewModel.isLoading, "로딩 상태가 false여야 합니다.")
        XCTAssertEqual(viewModel.photos.count, 2, "사진 개수가 2개여야 합니다.")
        XCTAssertEqual(viewModel.photos.first?.photoId, "1", "사진은 최신순으로 정렬되어야 합니다.")
        XCTAssertNil(viewModel.errorMessage, "에러 메시지는 nil이어야 합니다.")
    }

    func testSyncPhotos_Failure() async {
        // Given: UseCase가 에러를 발생시키도록 설정
        mockGetAllPhotosUseCase.result = .failure(TestError.general)

        // When: 사진 동기화 실행
        await viewModel.syncPhotos()

        // Then: 결과 검증
        XCTAssertFalse(viewModel.isLoading, "로딩 상태가 false여야 합니다.")
        XCTAssertTrue(viewModel.photos.isEmpty, "사진 배열은 비어있어야 합니다.")
        XCTAssertNotNil(viewModel.errorMessage, "에러 메시지가 존재해야 합니다.")
        XCTAssertEqual(viewModel.errorMessage, "네트워크/파싱 오류: \(TestError.general.localizedDescription)")
    }

    // MARK: - deletePhotos() Tests

    func testDeletePhotos_Success() async {
        // Given: Delete UseCase는 성공, 그 후 호출될 Get UseCase는 빈 배열을 반환하도록 설정
        mockDeletePhotosUseCase.errorToThrow = nil
        mockGetAllPhotosUseCase.result = .success([]) // 삭제 후 동기화 시 빈 배열을 반환
        let photoIdsToDelete = ["p1", "p2"]

        // When: 사진 삭제 실행
        await viewModel.deletePhotos(photoIds: photoIdsToDelete)

        // Then: 결과 검증
        XCTAssertFalse(viewModel.isLoading, "로딩 상태가 false여야 합니다.")
        XCTAssertEqual(mockDeletePhotosUseCase.calledWithPhotoIds, photoIdsToDelete, "올바른 photoId로 삭제가 호출되어야 합니다.")
        XCTAssertTrue(viewModel.photos.isEmpty, "삭제 후 사진 배열은 비어있어야 합니다.")
        XCTAssertNil(viewModel.errorMessage, "에러 메시지는 nil이어야 합니다.")
    }

    func testDeletePhotos_Failure() async {
        // Given: Delete UseCase가 에러를 발생시키도록 설정
        mockDeletePhotosUseCase.errorToThrow = TestError.general
        let photoIdsToDelete = ["p1"]

        // When: 사진 삭제 실행
        await viewModel.deletePhotos(photoIds: photoIdsToDelete)

        // Then: 결과 검증
        XCTAssertFalse(viewModel.isLoading, "로딩 상태가 false여야 합니다.")
        XCTAssertNotNil(viewModel.errorMessage, "에러 메시지가 존재해야 합니다.")
        XCTAssertEqual(viewModel.errorMessage, "삭제 실패: \(TestError.general.localizedDescription)")
    }
}
