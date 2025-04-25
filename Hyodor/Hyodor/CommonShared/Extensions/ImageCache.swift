//
//  ImageCache.swift
//  Hyodor
//
//  Created by 김상준 on 4/25/25.
//

import SwiftUI

// 이미지 캐싱 시스템: 메모리와 디스크에서 이미지를 관리
class ImageCache {
    static let shared = ImageCache() // 싱글톤 전역 관리
    private let memoryCache = NSCache<NSString, UIImage>() //메모리 캐시
    private let fileManager = FileManager.default // 디스크 캐시

    // 디스크 캐시 경로
    private var diskCacheURL: URL {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return caches.appendingPathComponent("SharedAlbumImageCache")
    }

    // 초기화
    private init() {
        // 디스크 캐시 폴더 생성
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }

    // MARK: 메모리 또는 디스크 캐시에서 이미지를 가져옴
    // - Parameters:
    //  - key: 이미지를 식별하는 고유 문자열 (예: URL)
    //  - Returns: 캐시된 UIImage 객체 또는 nil (캐시에 없으면)
    func get(forKey key: String) -> UIImage? {
        // 1. 메모리 캐시(NSCache)에서 이미지 확인
        if let img = memoryCache.object(forKey: key as NSString) {
            return img
        }
        // 2. 메모리에 없으면 디스크 캐시에서 이미지 로드
        let diskURL = diskCacheURL.appendingPathComponent(key.sha256())

        // 3. 디스크에서 데이터를 읽고 UIImage로 변환
        // 변환된 이미지는 메모리 캐시에 저장하여 다음 접근 속도를 높임
        if let data = try? Data(contentsOf: diskURL), let img = UIImage(data: data) {
            memoryCache.setObject(img, forKey: key as NSString)
            return img
        }
        // 4. 캐시에 이미지가 없으면 nil 반환
        return nil
    }

    // MARK: 메모리와 디스크 캐시에 이미지를 저장
    // - Parameters:
    //   - image: 저장할 UIImage 객체
    //   - key: 이미지를 식별하는 고유 문자열 (예: URL)
    func set(_ image: UIImage, forKey key: String) {
        // 1. 메모리 캐시(NSCache)에 이미지 저장
        memoryCache.setObject(image, forKey: key as NSString)
        // 2. 디스크 캐시 경로 생성 (SHA256 해시로 파일명 충돌 방지)
        let diskURL = diskCacheURL.appendingPathComponent(key.sha256())
        // 3. 이미지를 JPEG 데이터로 변환 (압축 품질 90%) 후 디스크에 저장
        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: diskURL)
        }
    }
}
