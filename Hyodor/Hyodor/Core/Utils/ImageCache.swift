//
//  ImageCache.swift
//  Hyodor
//
//  Created by 김상준 on 4/25/25.
//

import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default

    private var diskCacheURL: URL {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return caches.appendingPathComponent("SharedAlbumImageCache")
    }

    private init() {
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }

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

    func set(_ image: UIImage, forKey key: String) {
        memoryCache.setObject(image, forKey: key as NSString)
        let diskURL = diskCacheURL.appendingPathComponent(key.sha256())
        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: diskURL)
        }
    }
}
