//
//  PhotoListView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI
import Photos

struct LocalPhotoListView: View {
    @State var viewModel: LocalPhotoListVM
    var onUploadComplete: ((SyncResponseDTO) -> Void)?

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
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(viewModel.photoAssets) { photoModel in
                            LocalPhotoCell(
                                asset: photoModel.asset,
                                isSelected: photoModel.isSelected,
                                isUploaded: photoModel.isUploaded,
                                onTap: {
                                    viewModel.handleTap(assetId: photoModel.id)
                                }
                            )
                        }
                    }
                }

                uploadButton
            }
            .navigationTitle("사진 선택")
            .onAppear {
                viewModel.requestPhotoLibraryAccess()
            }
            .alert(item: $viewModel.activeAlert) { alertType in
                createAlert(for: alertType)
            }

            if viewModel.isUploading {
                UploadingOverlay()
            }
        }
        .animation(.easeInOut, value: viewModel.isUploading)
    }

    private var uploadButton: some View {
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
    }

    private func createAlert(for alertType: LocalPhotoListVM.AlertType) -> Alert {
        switch alertType {
        case .permission:
            return Alert(title: Text("사진첩 접근 불가"), message: Text("설정에서 권한을 허용해주세요."), dismissButton: .default(Text("확인")))
        case .duplicate:
            return Alert(title: Text("중복 사진"), message: Text("이 사진은 이미 업로드되었습니다."), dismissButton: .default(Text("확인")))
        case .uploadSuccess(let count):
            let message = "\(count)장의 사진이 공유 앨범에 업로드되었습니다."
            return Alert(title: Text("업로드 완료"), message: Text(message), dismissButton: .default(Text("확인")))
        case .uploadFailure(let error):
            return Alert(title: Text("업로드 실패"), message: Text(error), dismissButton: .default(Text("확인")))
        }
    }
}

struct UploadingOverlay: View {
    var body: some View {
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
