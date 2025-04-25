//
//  SharedPhotoDetailViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/25/25.
//

import SwiftUI

@Observable
class SharedPhotoDetailViewModel {
    var image: UIImage?
    var isLoading: Bool  = true

    private let photo: SharedPhoto

    init(photo: SharedPhoto) {
           self.photo = photo
           Task { await loadImage() }
       }

    func loadImage() async {
        guard let url = photo.imageURL else {
            isLoading = false
            return
        }
        if let cached = ImageCache.shared.get(forKey: url.absoluteString) {
            self.image = cached
            self.isLoading = false
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                ImageCache.shared.set(uiImage, forKey: url.absoluteString)
                self.image = uiImage
            }
            self.isLoading = false
        } catch {
            self.isLoading = false
        }
    }

}
