//
//  SharedAlbumView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI
import Photos

struct SharedAlbumView: View {
    @StateObject private var albumModel = SharedAlbumModel()
    @State private var showingPhotoList = false
    @State private var showingUploadSuccess = false

    // 그리드 레이아웃
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack {
                    if albumModel.isLoading {
                        ProgressView("로딩 중...")
                    } else if albumModel.photos.isEmpty {
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
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 2) {
                                ForEach(albumModel.photos) { photo in
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
                        Button(action: {
                            showingPhotoList = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingPhotoList) {
                    // 사진 선택 후 돌아오면 앨범 새로고침
                    albumModel.loadSharedPhotos()
                } content: {
                    NavigationView {
                        PhotoListView(viewModel: PhotoListViewModel(), onUploadComplete: { response in
                            // 업로드 완료 콜백
                            albumModel.addNewPhotos(from: response)
                            showingPhotoList = false
                            showingUploadSuccess = true
                        })
                    }
                }
                .alert("업로드 완료", isPresented: $showingUploadSuccess) {
                    Button("확인", role: .cancel) {}
                } message: {
                    Text("사진이 공유 앨범에 추가되었습니다.")
                }
                .onAppear {
                    albumModel.loadSharedPhotos()
                }
            }
        }
    }
}
