//
//  PhotoListView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI
import Photos

struct PhotoListView: View {
    @ObservedObject var viewModel: PhotoListViewModel
    var onUploadComplete: ((UploadCompleteResponse) -> Void)?

    // spacing 0으로!
    private let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) { // spacing 0!
                        ForEach(viewModel.photoAssets) { photoModel in
                            PhotoCell(
                                asset: photoModel.asset,
                                isSelected: photoModel.isSelected,
                                isUploaded: photoModel.isUploaded,
                                onTap: {
                                    viewModel.handleTap(assetId: photoModel.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 0)
                }

                // 업로드 버튼
                Button(action: {
                    Task {
                        await viewModel.uploadSelectedPhotos { response in
                            onUploadComplete?(response)
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isUploading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 20))
                        }
                        Text(viewModel.isUploading ? "업로드 중..." : "업로드")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        !viewModel.hasSelectedPhotos || viewModel.isUploading
                            ? Color.gray
                            : Color.blue
                    )
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .disabled(!viewModel.hasSelectedPhotos || viewModel.isUploading)
                .accessibilityLabel(viewModel.isUploading ? "업로드 중" : "사진 업로드")
                .accessibilityHint(!viewModel.hasSelectedPhotos ? "사진을 선택해야 업로드할 수 있습니다." : "선택한 사진을 공유 앨범에 업로드합니다.")
            }
            .navigationTitle("사진 선택")
            .onAppear {
                viewModel.requestPhotoLibraryAccess()
            }
            .alert("사진첩 접근 불가", isPresented: $viewModel.showingPermissionAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("설정에서 권한을 허용해주세요.")
            }
            .alert("중복 사진", isPresented: $viewModel.showingDuplicateAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("이 사진은 이미 업로드되었습니다.")
            }
            .alert("업로드 완료", isPresented: $viewModel.showingUploadSuccess) {
                Button("확인", role: .cancel) {}
            } message: {
                VStack {
                    Text("🎉 \(viewModel.uploadSuccessCount)장의 사진이 공유 앨범에 업로드되었습니다.")
                    Text("업로드된 사진은 녹색 뱃지로 표시됩니다.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 업로드 중 오버레이
            if viewModel.isUploading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)

                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)

                    Text("사진 업로드 중...")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("잠시만 기다려주세요")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.8))
                )
                .shadow(radius: 10)
            }
        }
        .animation(.easeInOut, value: viewModel.isUploading)
    }
}
