//
//  PhotoListView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI
import Photos

struct PhotoListView: View {
    @State private var photoAssets: [PHAsset] = [] // 사진첩에서 가져온 PHAsset 목록
    @State private var selectedAssets: Set<String> = [] // 선택된 사진의 localIdentifier
    @State private var uploadedAssets: Set<String> = [] // 업로드된 사진의 localIdentifier
    @State private var showingPermissionAlert = false // 권한 거부 알림
    @State private var showingDuplicateAlert = false // 중복 알림
    @State private var showingUploadSuccess = false // 업로드 성공 알림
    @State private var isUploading = false // 업로드 중 상태

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(photoAssets, id: \.localIdentifier) { asset in
                            PhotoCell(
                                asset: asset,
                                isSelected: selectedAssets.contains(asset.localIdentifier),
                                isUploaded: uploadedAssets.contains(asset.localIdentifier)
                            )
                            .onTapGesture {
                                handleTap(on: asset)
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                }

                // 업로드 버튼
                Button(action: uploadSelectedPhotos) {
                    HStack(spacing: 8) {
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 20))
                        }
                        Text(isUploading ? "업로드 중..." : "업로드")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        selectedAssets.isEmpty || isUploading
                            ? Color.gray
                            : Color.blue
                    )
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .disabled(selectedAssets.isEmpty || isUploading)
                .accessibilityLabel(isUploading ? "업로드 중" : "사진 업로드")
                .accessibilityHint(selectedAssets.isEmpty ? "사진을 선택해야 업로드할 수 있습니다." : "선택한 사진을 공유 앨범에 업로드합니다.")
            }
            .navigationTitle("사진첩")
            .onAppear {
                requestPhotoLibraryAccess()
            }
            .alert("사진첩 접근 불가", isPresented: $showingPermissionAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("설정에서 권한을 허용해주세요.")
            }
            .alert("중복 사진", isPresented: $showingDuplicateAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("이 사진은 이미 업로드되었습니다.")
            }
            .alert("업로드 완료", isPresented: $showingUploadSuccess) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("\(selectedAssets.count)장의 사진이 공유 앨범에 업로드되었습니다.")
            }
        }
    }

    // MARK: - 사진첩 접근 권한 요청
    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("사진첩 접근 권한 획득")
                    fetchPhotos()
                case .denied, .restricted:
                    print("사진첩 접근 권한 거부됨")
                    showingPermissionAlert = true
                default:
                    break
                }
            }
        }
    }

    // MARK: - 사진 가져오기
    private func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var assets: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        photoAssets = assets
    }

    // MARK: - 사진 탭 처리
    private func handleTap(on asset: PHAsset) {
        let id = asset.localIdentifier
        if uploadedAssets.contains(id) {
            showingDuplicateAlert = true // 이미 업로드된 경우 알림
        } else {
            if selectedAssets.contains(id) {
                selectedAssets.remove(id) // 선택 해제
            } else {
                selectedAssets.insert(id) // 선택
            }
        }
    }

    // MARK: - 업로드 처리
    private func uploadSelectedPhotos() {
        guard !selectedAssets.isEmpty, !isUploading else { return }
        isUploading = true

        // 업로드 시뮬레이션 (당신이 실제 로직으로 대체)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.uploadedAssets.formUnion(self.selectedAssets)
            self.selectedAssets.removeAll()
            self.isUploading = false
            self.showingUploadSuccess = true
        }
    }
}

// MARK: - 사진 셀
private struct PhotoCell: View {
    let asset: PHAsset
    let isSelected: Bool
    let isUploaded: Bool
    @State private var image: Image?

    // 셀 크기 계산
    private var cellSize: CGFloat {
        (UIScreen.main.bounds.width - 4) / 3 // 3열, 2포인트 간격 고려
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let image = image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: cellSize, height: cellSize) // 고정된 정사각형 크기
                        .clipped() // 잘리는 부분 처리
                } else {
                    Color.gray
                        .frame(width: cellSize, height: cellSize)
                }
            }
            .overlay {
                if isUploaded {
                    Color.black.opacity(0.4) // 업로드된 사진 반투명 오버레이
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
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                    Text("업로드됨")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(4)
                }
            }
        }
        .onAppear {
            loadImage()
        }
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

// MARK: - 프리뷰
struct PhotoListView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoListView()
            .preferredColorScheme(.light)
    }
}
