//
//  HyodorTests.swift
//  HyodorTests
//
//  Created by 김상준 on 4/14/25.
//

// Tests/Repositories/NotificationRepositoryTests.swift
import XCTest
@testable import Hyodor

class NotificationRepositoryTests: XCTestCase {
    var repository: NotificationRepositoryImpl!
    var mockUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "test")
        repository = NotificationRepositoryImpl(userDefaults: mockUserDefaults)
    }

    override func tearDown() {
        mockUserDefaults.removePersistentDomain(forName: "test")
        super.tearDown()
    }

    func testSaveAndGetNotifications() {
        // Given
        let notifications = [
            NotificationData(
                title: "테스트 알림",
                body: "테스트 내용",
                videoUrl: "https://test.com/video.mp4",
                userId: "testUser",
                receivedDate: Date()
            )
        ]

        // When
        repository.saveNotifications(notifications)
        let result = repository.getNotifications()

        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].title, "테스트 알림")
        XCTAssertEqual(result[0].videoUrl, "https://test.com/video.mp4")
    }

    func testGetNotifications_SortedByDate() {
        // Given
        let oldNotification = NotificationData(
            title: "오래된 알림",
            body: "내용",
            videoUrl: "https://test.com/old.mp4",
            userId: "testUser",
            receivedDate: Date().addingTimeInterval(-3600)
        )

        let newNotification = NotificationData(
            title: "새로운 알림",
            body: "내용",
            videoUrl: "https://test.com/new.mp4",
            userId: "testUser",
            receivedDate: Date()
        )

        // When
        repository.saveNotifications([oldNotification, newNotification])
        let result = repository.getNotifications()

        // Then
        XCTAssertEqual(result[0].title, "새로운 알림") // 최신 알림이 첫 번째
        XCTAssertEqual(result[1].title, "오래된 알림")
    }
}
