//
//  SharedPhotoDetailView.swift
//  Hyodor
//
//  Created by 김상준 on 4/25/25.
//
import SwiftUI

struct SharedPhotoDetailView: View {
    let photo: SharedPhoto
    @State private var image: UIImage?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
