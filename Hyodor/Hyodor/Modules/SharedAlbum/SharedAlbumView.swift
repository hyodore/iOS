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
    @State private var selectedPhoto: SharedPhoto? = nil

    // 선택/삭제 관련 상태
    @State private var isSelectionMode = false
    @State private var selectedPhotoIds: Set<String> = []

    private let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
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
                        if isSelectionMode {
                            // 선택 모드 시 선택된 개수 표시
                            HStack {
                                Text("선택됨: \(selectedPhotoIds.count)개")
                                    .foregroundColor(.blue)
                                    .font(.subheadline)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 2) {
                                ForEach(viewModel.photos) { photo in
                                    ZStack(alignment: .topTrailing) {
                                        // 셀 탭 동작 분기
                                        Group {
                                            if isSelectionMode {
                                                SharedPhotoCell(photo: photo)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(selectedPhotoIds.contains(photo.photoId) ? Color.blue : Color.gray.opacity(0.5), lineWidth: 2)
                                                            .frame(width: 26, height: 26)
                                                            .padding(6)
                                                    )
                                                    .opacity(selectedPhotoIds.contains(photo.photoId) ? 0.7 : 1.0)
                                                    .onTapGesture {
                                                        if selectedPhotoIds.contains(photo.photoId) {
                                                            selectedPhotoIds.remove(photo.photoId)
                                                        } else {
                                                            selectedPhotoIds.insert(photo.photoId)
                                                        }
                                                    }
                                            } else {
                                                NavigationLink(
                                                    destination: SharedPhotoDetailView(photo: photo)
                                                ) {
                                                    SharedPhotoCell(photo: photo)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        // 선택 모드일 때 체크마크 표시
                                        if isSelectionMode {
                                            ZStack {
                                                Circle()
                                                    .fill(selectedPhotoIds.contains(photo.photoId) ? Color.blue : Color.white)
                                                    .frame(width: 22, height: 22)
                                                    .shadow(radius: 1)
                                                if selectedPhotoIds.contains(photo.photoId) {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 12, weight: .bold))
                                                }
                                            }
                                            .padding(7)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                }
                .navigationTitle("공유 앨범")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        // 선택 모드: 삭제 버튼
                        if isSelectionMode {
                            Button {
                                Task {
                                    await viewModel.deletePhotos(photoIds: Array(selectedPhotoIds))
                                    selectedPhotoIds.removeAll()
                                    isSelectionMode = false
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(selectedPhotoIds.isEmpty ? .gray : .red)
                            }
                            .disabled(selectedPhotoIds.isEmpty)
                        } else {
                            // 일반 모드: + 버튼
                            Button {
                                showingPhotoList = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                        // 선택/완료 토글 버튼
                        Button {
                            withAnimation {
                                isSelectionMode.toggle()
                                selectedPhotoIds.removeAll()
                            }
                        } label: {
                            Text(isSelectionMode ? "완료" : "선택")
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
