//
//  SharedAlbumView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI
import Photos

struct SharedAlbumView: View {
    @State private var sharedPhotos: [SharedPhoto] = [] // 공유 앨범의 사진
    @State private var selectedPhotoIds: Set<String> = [] // 선택된 사진 ID
    @State private var isDeleting = false // 삭제 중 상태
    @State private var isSelectionMode = false // 다중 선택 모드
    @State private var selectedPhoto: SharedPhoto? // 상세 뷰로 전달할 사진

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 상단 선택 버튼
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                isSelectionMode.toggle()
                                selectedPhotoIds.removeAll() // 모드 전환 시 선택 초기화
                            }
                        }) {
                            Text(isSelectionMode ? "취소" : "선택")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        .accessibilityLabel(isSelectionMode ? "선택 모드 취소" : "사진 선택 모드")
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 16)

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(sharedPhotos) { photo in
                                SharedPhotoCell(
                                    photo: photo,
                                    isSelected: selectedPhotoIds.contains(photo.id),
                                    isSelectionMode: isSelectionMode
                                )
                                .onTapGesture {
                                    handleTap(on: photo)
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                    }

                    // 삭제 버튼 (선택 모드에서만 표시)
                    if isSelectionMode {
                        Button(action: deleteSelectedPhotos) {
                            HStack(spacing: 8) {
                                if isDeleting {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 20))
                                }
                                Text(isDeleting ? "삭제 중..." : "삭제")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                selectedPhotoIds.isEmpty || isDeleting
                                    ? Color.gray
                                    : Color.red
                            )
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                        .disabled(selectedPhotoIds.isEmpty || isDeleting)
                        .accessibilityLabel(isDeleting ? "삭제 중" : "사진 삭제")
                        .accessibilityHint(selectedPhotoIds.isEmpty ? "사진을 선택해야 삭제할 수 있습니다." : "선택한 사진을 공유 앨범에서 삭제합니다.")
                    }
                }
                .onAppear {
                    loadDummyPhotos() // 임의의 사진 로드
                }
                .navigationDestination(isPresented: Binding(
                    get: { selectedPhoto != nil },
                    set: { if !$0 { selectedPhoto = nil } }
                )) {
                    if let photo = selectedPhoto {
                        PhotoDetailView(photo: photo) // 상세 뷰
                    }
                }
            }
        }
    }

    // MARK: - 사진 모델
    struct SharedPhoto: Identifiable {
        let id: String
        let image: Image
    }

    // MARK: - 사진 탭 처리
    private func handleTap(on photo: SharedPhoto) {
        if isSelectionMode {
            let id = photo.id
            if selectedPhotoIds.contains(id) {
                selectedPhotoIds.remove(id) // 선택 해제
            } else {
                selectedPhotoIds.insert(id) // 선택
            }
        } else {
            selectedPhoto = photo // 상세 뷰로 이동
        }
    }

    // MARK: - 삭제 처리
    private func deleteSelectedPhotos() {
        guard !selectedPhotoIds.isEmpty, !isDeleting else { return }
        isDeleting = true

        // 삭제 시뮬레이션 (당신이 실제 로직으로 대체)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.sharedPhotos.removeAll { self.selectedPhotoIds.contains($0.id) }
            self.selectedPhotoIds.removeAll()
            self.isDeleting = false
        }
    }

    // MARK: - 임의의 사진 로드
    private func loadDummyPhotos() {
        sharedPhotos = [
            SharedPhoto(id: "1", image: Image(systemName: "photo")),
            SharedPhoto(id: "2", image: Image(systemName: "photo.fill")),
            SharedPhoto(id: "3", image: Image(systemName: "photo.on.rectangle")),
            SharedPhoto(id: "4", image: Image(systemName: "photo.fill.on.rectangle.fill")),
            SharedPhoto(id: "5", image: Image(systemName: "photo.circle"))
        ]
    }
}

// MARK: - 공유 앨범 사진 셀
struct SharedPhotoCell: View {
    let photo: SharedAlbumView.SharedPhoto
    let isSelected: Bool
    let isSelectionMode: Bool

    private var cellSize: CGFloat {
        (UIScreen.main.bounds.width - 4) / 3 // 3열, 2포인트 간격
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            photo.image
                .resizable()
                .scaledToFill()
                .frame(width: cellSize, height: cellSize)
                .clipped()

            // 선택 모드에서만 체크 표시
            if isSelectionMode && isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .padding(4)
            }
        }
        .accessibilityLabel(isSelectionMode && isSelected ? "선택된 공유 사진" : "공유 사진")
    }
}

// MARK: - 상세 뷰
struct PhotoDetailView: View {
    let photo: SharedAlbumView.SharedPhoto

    var body: some View {
        VStack {
            photo.image
                .resizable()
                .scaledToFit()
                .navigationTitle("사진 상세")
        }
    }
}

// MARK: - 프리뷰
struct SharedAlbumView_Previews: PreviewProvider {
    static var previews: some View {
        SharedAlbumView()
            .preferredColorScheme(.light)
    }
}
