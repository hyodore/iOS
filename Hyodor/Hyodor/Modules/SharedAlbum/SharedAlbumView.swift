//
//  SharedAlbumView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//
import SwiftUI

struct SharedAlbumView: View {
    @State private var viewModel = SharedAlbumViewModel()
    @State private var showingPhotoList = false

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack {
                    if viewModel.isLoading {
                        ProgressView("동기화 중...")
                    }
                    else if viewModel.photos.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("공유 앨범이 비어있습니다")
                                .font(.headline)
                            Text("오른쪽 상단의 + 버튼을 눌러\n사진을 추가해보세요")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                    else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 2) {
                                ForEach(viewModel.photos) { photo in
                                    SharedPhotoCell(photo: photo)
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                }
                .navigationTitle("공유 앨범")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingPhotoList = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingPhotoList, onDismiss: {
                    Task { await viewModel.syncPhotos() }
                }) {
                    NavigationView {
                        PhotoListView(viewModel: PhotoListViewModel(), onUploadComplete: { _ in
                            showingPhotoList = false
                        })
                    }
                }
                .task {
                    await viewModel.syncPhotos()
                }
                .refreshable {
                    await viewModel.syncPhotos()
                }
                .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
                    Button("확인", role: .cancel) { viewModel.errorMessage = nil }
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
            }
        }
    }
}
