//
//  SharedPhotoCell.swift
//  Hyodor
//
//  Created by 김상준 on 4/24/25.
//

import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}

    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func get(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
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
            isLoading = false
            if let data = data, let uiImage = UIImage(data: data) {
                ImageCache.shared.set(uiImage, forKey: url.absoluteString)
                DispatchQueue.main.async { self.image = uiImage }
            }
        }.resume()
    }
}

