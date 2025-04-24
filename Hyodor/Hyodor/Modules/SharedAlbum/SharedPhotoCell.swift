//
//  SharedPhotoCell.swift
//  Hyodor
//
//  Created by 김상준 on 4/24/25.
//

import SwiftUI

struct SharedPhotoCell: View {
    let photo: SharedPhoto
    @State private var image: Image?
    @State private var isLoading = true

    private var cellSize: CGFloat {
        (UIScreen.main.bounds.width - 4) / 3
    }

    var body: some View {
        ZStack {
            if let image = image {
                image
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
        guard let imageURL = photo.imageURL else {
            isLoading = false
            return
        }
        URLSession.shared.dataTask(with: imageURL) { data, _, _ in
            isLoading = false
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = Image(uiImage: uiImage)
                }
            }
        }.resume()
    }
}
