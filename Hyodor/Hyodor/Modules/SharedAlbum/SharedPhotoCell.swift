//
//  SharedPhotoCell.swift
//  Hyodor
//
//  Created by 김상준 on 4/24/25.
//

import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default

    // 디스크 캐시 경로
    private var diskCacheURL: URL {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return caches.appendingPathComponent("SharedAlbumImageCache")
    }

    private init() {
        // 디스크 캐시 폴더 생성
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }

    // 메모리/디스크에서 이미지 반환
    func get(forKey key: String) -> UIImage? {
        if let img = memoryCache.object(forKey: key as NSString) {
            return img
        }
        let diskURL = diskCacheURL.appendingPathComponent(key.sha256())
        if let data = try? Data(contentsOf: diskURL), let img = UIImage(data: data) {
            memoryCache.setObject(img, forKey: key as NSString)
            return img
        }
        return nil
    }

    // 메모리/디스크에 이미지 저장
    func set(_ image: UIImage, forKey key: String) {
        memoryCache.setObject(image, forKey: key as NSString)
        let diskURL = diskCacheURL.appendingPathComponent(key.sha256())
        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: diskURL)
        }
    }
}

// SHA256 해시(파일명 충돌 방지)
import CryptoKit
extension String {
    func sha256() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

struct SharedPhotoCell: View {
    let photo: SharedPhoto
    private var cellSize: CGFloat { (UIScreen.main.bounds.width - 4) / 3 }
    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cellSize, height: cellSize)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: cellSize, height: cellSize)
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear { loadImage() }
    }

    private func loadImage() {
        guard let url = photo.imageURL else { isLoading = false; return }
        if let cached = ImageCache.shared.get(forKey: url.absoluteString) {
            self.image = cached
            self.isLoading = false
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                ImageCache.shared.set(uiImage, forKey: url.absoluteString)
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            }
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }.resume()
    }
}
