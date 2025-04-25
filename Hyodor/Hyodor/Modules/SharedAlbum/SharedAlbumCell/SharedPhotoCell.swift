//
//  SharedPhotoCell.swift
//  Hyodor
//
//  Created by 김상준 on 4/24/25.
//

import SwiftUI

struct SharedPhotoCell: View {
    @State private var viewModel: SharedPhotoCellViewModel
    private var cellSize: CGFloat { UIScreen.main.bounds.width / 3 }

    init(photo: SharedPhoto) {
        _viewModel = State(wrappedValue: SharedPhotoCellViewModel(photo: photo))
    }

    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cellSize, height: cellSize)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: cellSize, height: cellSize)
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: cellSize, height: cellSize)
        .background(Color.clear)
        .contentShape(Rectangle())
    }
}
