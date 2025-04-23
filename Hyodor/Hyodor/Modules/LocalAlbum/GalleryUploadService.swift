//
//  GalleryUploadService.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

// MARK: - 네트워크 서비스
import Foundation
import UIKit

protocol GalleryUploadServiceProtocol {
    func requestPresignedURLs(imageInfos: [[String: String]], completion: @escaping (Result<[PresignedURLResponse], Error>) -> Void)
    func uploadImageToS3(image: UIImage, presignedURL: PresignedURLResponse, completion: @escaping (Bool) -> Void)
    func notifyUploadComplete(userId: String, uploadedPhotos: [UploadCompleteRequest.UploadedPhotoInfo], completion: @escaping (Result<UploadCompleteResponse, Error>) -> Void)
}

class GalleryUploadService: GalleryUploadServiceProtocol {
    // 서버 URL (실제 환경에 맞게 수정 필요)
    private let baseURL = "http://localhost:8080"

    // 1. Presigned URL 발급 요청
    func requestPresignedURLs(imageInfos: [[String: String]], completion: @escaping (Result<[PresignedURLResponse], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/gallery/upload/init") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: imageInfos, options: [])
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NSError(domain: "Server Error", code: -2, userInfo: nil)))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No Data", code: -3, userInfo: nil)))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let presignedURLs = try decoder.decode([PresignedURLResponse].self, from: data)
                    completion(.success(presignedURLs))
                } catch {
                    completion(.failure(error))
                }
            }

            task.resume()
        } catch {
            completion(.failure(error))
        }
    }

    // 2. S3에 이미지 업로드
    func uploadImageToS3(image: UIImage, presignedURL: PresignedURLResponse, completion: @escaping (Bool) -> Void) {
        guard let uploadURL = URL(string: presignedURL.uploadUrl) else {
            completion(false)
            return
        }

        var request = URLRequest(url: uploadURL)
        request.httpMethod = "PUT"

        // Content-Type 설정 (Presigned URL의 서명에 포함된 헤더와 일치해야 함)
        let contentType = presignedURL.uploadUrl.contains(".png") ? "image/png" : "image/jpeg"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        // 이미지 데이터 준비
        let imageData: Data?
        if contentType == "image/png" {
            imageData = image.pngData()
        } else {
            imageData = image.jpegData(compressionQuality: 0.9)
        }

        guard let data = imageData else {
            completion(false)
            return
        }

        let task = URLSession.shared.uploadTask(with: request, from: data) { _, response, error in
            if let error = error {
                print("업로드 에러: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                print("업로드 성공: \(presignedURL.photoId)")
                completion(true)
            } else {
                print("업로드 실패: \(presignedURL.photoId)")
                completion(false)
            }
        }

        task.resume()
    }

    // 3. 업로드 완료 알림
    func notifyUploadComplete(userId: String, uploadedPhotos: [UploadCompleteRequest.UploadedPhotoInfo], completion: @escaping (Result<UploadCompleteResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/gallery/upload/complete") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")

        let requestBody = UploadCompleteRequest(userId: userId, photos: uploadedPhotos)

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(requestBody)
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(NSError(domain: "Server Error", code: -2, userInfo: nil)))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No Data", code: -3, userInfo: nil)))
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(UploadCompleteResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }

            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
