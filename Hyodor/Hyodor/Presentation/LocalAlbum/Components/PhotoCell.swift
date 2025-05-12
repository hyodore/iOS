//
//  PhotoCell.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import SwiftUI
import Photos

// MARK: - 사진 셀
struct PhotoCell: View {
    let asset: PHAsset
    let isSelected: Bool
    let isUploaded: Bool
    let onTap: () -> Void
    @State private var image: Image?

    // 셀 크기 계산 (spacing 0 기준)
    private var cellSize: CGFloat {
        UIScreen.main.bounds.width / 3
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: cellSize, height: cellSize)
                        .clipped()
                } else {
                    Color.gray
                        .frame(width: cellSize, height: cellSize)
                }
            }
            .overlay {
                if isUploaded {
                    Color.black.opacity(0.4)
                }
            }

            // 선택 표시
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .padding(4)
            }

            // 업로드된 표시
            if isUploaded {
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
        .frame(width: cellSize, height: cellSize)
        .background(Color.clear)            // 터치 영역 보장
        .contentShape(Rectangle())          // 셀 전체가 터치 영역
        .onTapGesture { onTap() }           // 터치 콜백을 이곳에!
        .onAppear { loadImage() }
        .accessibilityLabel(isUploaded ? "이미 업로드된 사진" : isSelected ? "선택된 사진" : "사진, \(asset.creationDate?.formatted() ?? "날짜 미상")")
        .accessibilityAddTraits(isUploaded ? .isStaticText : [])
    }

    private func loadImage() {
        let manager = PHImageManager.default()
        let targetSize = CGSize(width: 200, height: 200)
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat

        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { uiImage, _ in
            DispatchQueue.main.async {
                if let uiImage = uiImage {
                    self.image = Image(uiImage: uiImage)
                }
            }
        }
    }
}

