//
//  AsyncPhotoView.swift
//  Hyodor
//
//  Created by 김상준 on 6/12/25.
//

import SwiftUI
import Photos

struct AsyncPhotoView: View {
    let asset: PHAsset
    private let displaySize: CGFloat

    @State private var image: Image?

    init(asset: PHAsset, displaySize: CGFloat) {
        self.asset = asset
        self.displaySize = displaySize
    }

    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.3))
            }
        }
        .task {
            await loadImage()
        }
    }

    private func loadImage() async {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast

        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: displaySize * scale, height: displaySize * scale)

        let resultImage: UIImage? = await withCheckedContinuation { continuation in
            manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                continuation.resume(returning: image)
            }
        }

        if let uiImage = resultImage {
            await MainActor.run {
                self.image = Image(uiImage: uiImage)
            }
        }
    }
}
