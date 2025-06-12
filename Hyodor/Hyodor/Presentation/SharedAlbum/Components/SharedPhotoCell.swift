//
//  SharedPhotoCell.swift
//  Hyodor
//
//  Created by 김상준 on 4/24/25.
//

import SwiftUI
import Kingfisher

struct SharedPhotoCell: View {
    let photo: SharedPhoto
    private var cellSize: CGFloat { UIScreen.main.bounds.width / 3 }

    var body: some View {
        KFImage(photo.imageURL)
            .placeholder {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                    ProgressView()
                }
            }
            .retry(maxCount: 3, interval: .seconds(5)) 
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: cellSize, height: cellSize)
            .clipped()
            .contentShape(Rectangle())
    }
}
