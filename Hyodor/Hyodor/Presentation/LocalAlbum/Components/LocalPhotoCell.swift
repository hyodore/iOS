//
//  PhotoCell.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import SwiftUI
import Photos

struct LocalPhotoCell: View {
    let asset: PHAsset
    let isSelected: Bool
    let isUploaded: Bool
    let onTap: () -> Void

    private var cellSize: CGFloat {
        UIScreen.main.bounds.width / 3
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AsyncPhotoView(asset: asset, displaySize: cellSize)
                .frame(width: cellSize, height: cellSize)
                .clipped()

            // MARK: - Overlays
            if isUploaded {
                Color.black.opacity(0.4)

            }

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .padding(4)
            }

            if isUploaded {
                uploadedBadge
            }
        }
        .frame(width: cellSize, height: cellSize)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .accessibilityLabel(isUploaded ? "이미 업로드된 사진" : isSelected ? "선택된 사진" : "사진, \(asset.creationDate?.formatted() ?? "날짜 미상")")
    }

    private var uploadedBadge: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 32, height: 32)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            }
            .shadow(radius: 2)

            Text("업로드됨")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(Color.green)
                        .shadow(radius: 1)
                )
        }
        .padding(8)
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(), value: isUploaded)
    }
}
