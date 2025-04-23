//
//  HyodorTests.swift
//  HyodorTests
//
//  Created by 김상준 on 4/14/25.
//

import Testing
import SwiftUI

@testable import Hyodor
import Combine
// 테스트에서 사용할 Mock 서비스구현
    class MockGalleryUploadService : GalleryUploadServiceProtocol{
    // 성공 시뮬레이션 여부 (테스트 중 변경 가능) 
    var shouldSucceed = true
    // 지연 시간 (실제 네트워크 지연 시뮬레이션) 
    var delay: TimeInterval = 0.1 // 테스트에서는 빠르게 실행하기 위해 짧게 설정
    // 1. Presigned URL 발급 요청 모의 구현
    func requestPresignedURLs(imageInfos: [[String: String]], completion: @escaping (Result<[PresignedURLResponse], Error>) -> Void) {
        // 네트워크 지연 시뮬레이션
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            if self.shouldSucceed {
                // 성공 응답 생성
                var mockResponses: [PresignedURLResponse] = []

                for (index, info) in imageInfos.enumerated() {
                    let fileName = info["fileName"] ?? "unknown.jpg"
                    let isJpg = fileName.hasSuffix(".jpg") || fileName.hasSuffix(".jpeg")
                    let fileExtension = isJpg ? "jpg" : "png"

                    // 고유 ID 생성
                    let uuid = UUID().uuidString

                    // 모의 응답 생성
                    let response = PresignedURLResponse(
                        photoId: uuid,
                        uploadUrl: "https://mock-s3-bucket.amazonaws.com/photos/$$uuid).$$fileExtension)?mock-presigned-url=true",
                        photoUrl: "https://mock-s3-bucket.amazonaws.com/photos/$$uuid).$$fileExtension)"
                    )

                    mockResponses.append(response)
                }

                completion(.success(mockResponses))
            } else {
                // 실패 시뮬레이션
                let error = NSError(domain: "MockServiceError", code: 500, userInfo: [NSLocalizedDescriptionKey: "모의 서버 오류"])
                completion(.failure(error))
            }
        }
    }

    // 2. S3에 이미지 업로드 모의 구현
    func uploadImageToS3(image: UIImage, presignedURL: PresignedURLResponse, completion: @escaping (Bool) -> Void) {
        // 네트워크 지연 시뮬레이션
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            completion(self.shouldSucceed)
        }
    }

    // 3. 업로드 완료 알림 모의 구현
    func notifyUploadComplete(userId: String, uploadedPhotos: [UploadCompleteRequest.UploadedPhotoInfo], completion: @escaping (Result<UploadCompleteResponse, Error>) -> Void) {
        // 네트워크 지연 시뮬레이션
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            if self.shouldSucceed {
                // 현재 시간을 ISO8601 형식으로 변환
                let dateFormatter = ISO8601DateFormatter()
                let currentTime = dateFormatter.string(from: Date())

                // 모의 응답 생성
                var newPhotos: [UploadCompleteResponse.PhotoInfo] = []

                for photo in uploadedPhotos {
                    let photoInfo = UploadCompleteResponse.PhotoInfo(
                        photoId: photo.photoId,
                        familyId: "mock-family-123",
                        photoUrl: photo.photoUrl,
                        uploadedBy: userId,
                        uploadedAt: currentTime,
                        deleted: false,
                        deletedAt: nil
                    )
                    newPhotos.append(photoInfo)
                }

                // 항상 있는 샘플 사진 추가
                let alwaysNewPhoto = UploadCompleteResponse.PhotoInfo(
                    photoId: "always_new",
                    familyId: "mock-family-123",
                    photoUrl: "https://mock-s3-bucket.amazonaws.com/photos/sample.jpg",
                    uploadedBy: userId,
                    uploadedAt: currentTime,
                    deleted: false,
                    deletedAt: nil
                )
                newPhotos.append(alwaysNewPhoto)

                // 삭제된 사진 샘플
                let deletedPhoto = UploadCompleteResponse.PhotoInfo(
                    photoId: "always_deleted",
                    familyId: "mock-family-123",
                    photoUrl: "https://mock-s3-bucket.amazonaws.com/photos/deleted.jpg",
                    uploadedBy: userId,
                    uploadedAt: dateFormatter.string(from: Date().addingTimeInterval(-86400)),
                    deleted: true,
                    deletedAt: currentTime
                )

                let response = UploadCompleteResponse(
                    syncedAt: currentTime,
                    newPhoto: newPhotos,
                    deletedPhoto: [deletedPhoto]
                )

                completion(.success(response))
            } else {
                // 실패 시뮬레이션
                let error = NSError(domain: "MockServiceError", code: 500, userInfo: [NSLocalizedDescriptionKey: "모의 서버 오류"])
                completion(.failure(error))
            }
        }
    }
}
struct GalleryUploadTests {
    @Test func testMockServicePresignedURLRequest() async throws {
        // 모의 서비스 생성
        let mockService = MockGalleryUploadService()

        // 테스트 데이터 준비
        let imageInfos: [[String: String]] = [
            ["fileName": "test1.jpg", "contentType": "image/jpeg"],
            ["fileName": "test2.png", "contentType": "image/png"]
        ]

        // 비동기 결과를 기다리기 위한 continuation 사용
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[PresignedURLResponse], Error>) in
            mockService.requestPresignedURLs(imageInfos: imageInfos) { result in
                switch result {
                case .success(let responses):
                    continuation.resume(returning: responses)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        // 결과 검증
        #expect(result.count == 2)
        #expect(result.photoId.isEmpty == false)
        #expect(result.uploadUrl.contains("mock-s3-bucket"))
        #expect(result.photoUrl.contains(".png"))
    }

    @Test func testMockServiceUploadImage() async throws {
        // 모의 서비스 생성
        let mockService = MockGalleryUploadService()

        // 테스트 이미지 생성 (1x1 픽셀 이미지)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let image = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }

        // 테스트 presigned URL 응답 생성
        let presignedURL = PresignedURLResponse(
            photoId: "test-id",
            uploadUrl: "https://mock-s3-bucket.amazonaws.com/photos/test-id.jpg",
            photoUrl: "https://mock-s3-bucket.amazonaws.com/photos/test-id.jpg"
        )

        // 성공 케이스 테스트
        mockService.shouldSucceed = true

        let success = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            mockService.uploadImageToS3(image: image, presignedURL: presignedURL) { success in
                continuation.resume(returning: success)
            }
        }

        // 결과 검증
        #expect(success == true)

        // 실패 케이스 테스트
        mockService.shouldSucceed = false

        let failure = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            mockService.uploadImageToS3(image: image, presignedURL: presignedURL) { success in
                continuation.resume(returning: success)
            }
        }

        // 결과 검증
        #expect(failure == false)
    }

    @Test func testMockServiceCompleteUpload() async throws {
        // 모의 서비스 생성
        let mockService = MockGalleryUploadService()

        // 테스트 데이터 준비
        let userId = "test-user"
        let uploadedPhotos = [
            UploadCompleteRequest.UploadedPhotoInfo(
                photoId: "photo-1",
                photoUrl: "https://example.com/photo-1.jpg",
                uploadAt: "2023-04-23T12:34:56Z"
            ),
            UploadCompleteRequest.UploadedPhotoInfo(
                photoId: "photo-2",
                photoUrl: "https://example.com/photo-2.png",
                uploadAt: "2023-04-23T12:35:00Z"
            )
        ]

        // 비동기 결과를 기다리기 위한 continuation 사용
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UploadCompleteResponse, Error>) in
            mockService.notifyUploadComplete(userId: userId, uploadedPhotos: uploadedPhotos) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        // 결과 검증
        #expect(result.syncedAt.isEmpty == false)
        #expect(result.newPhoto.count >= 3) // 2개 업로드 + 항상 있는 샘플 사진

        // 업로드된 사진 ID 확인
        let photoIds = result.newPhoto.map { $0.photoId }
        #expect(photoIds.contains("always_new"))
    }

    @Test func testMockServiceFailure() async throws {
        // 모의 서비스 생성 (실패 모드)
        let mockService = MockGalleryUploadService()
        mockService.shouldSucceed = false

        // 테스트 데이터 준비
        let imageInfos: [[String: String]] = [
            ["fileName": "test1.jpg", "contentType": "image/jpeg"]
        ]

        // 실패 케이스 테스트
        do {
            _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[PresignedURLResponse], Error>) in
                mockService.requestPresignedURLs(imageInfos: imageInfos) { result in
                    switch result {
                    case .success(let responses):
                        continuation.resume(returning: responses)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
//            throw TestFailure("Expected to Throw an error")
        } catch {
            // 에러가 발생해야 함
            #expect(error is NSError)
            let nsError = error as NSError
            #expect(nsError.domain == "MockServiceError")
            #expect(nsError.code == 500)
        }
    }

    @Test func testMultipleUploads() async throws {
        // 모의 서비스 생성
        let mockService = MockGalleryUploadService()

        // 테스트 데이터 준비
        let imageInfos: [[String: String]] = [
            ["fileName": "test1.jpg", "contentType": "image/jpeg"],
            ["fileName": "test2.png", "contentType": "image/png"],
            ["fileName": "test3.jpg", "contentType": "image/jpeg"]
        ]

        // 첫 번째 요청
        let result1 = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[PresignedURLResponse], Error>) in
            mockService.requestPresignedURLs(imageInfos: imageInfos) { result in
                switch result {
                case .success(let responses):
                    continuation.resume(returning: responses)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        #expect(result1.count == 3)

        // 두 번째 요청 (다른 이미지 세트)
        let imageInfos2: [[String: String]] = [
            ["fileName": "another1.jpg", "contentType": "image/jpeg"],
            ["fileName": "another2.png", "contentType": "image/png"]
        ]

        let result2 = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[PresignedURLResponse], Error>) in
            mockService.requestPresignedURLs(imageInfos: imageInfos2) { result in
                switch result {
                case .success(let responses):
                    continuation.resume(returning: responses)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        #expect(result2.count == 2)

        // 두 결과가 서로 다른지 확인
        let ids1 = Set(result1.map { $0.photoId })
        let ids2 = Set(result2.map { $0.photoId })
        let intersection = ids1.intersection(ids2)

        #expect(intersection.isEmpty)
    }


}
