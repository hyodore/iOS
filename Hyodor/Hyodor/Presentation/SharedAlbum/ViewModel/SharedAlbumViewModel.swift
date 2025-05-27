//
//  SharedAlbumViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/24/25.
//

import SwiftUI

@Observable
class SharedAlbumViewModel {
    var photos: [SharedPhoto] = []
    var isLoading = false
    var errorMessage: String?

    private let getAllPhotosUseCase: GetAllPhotosUseCase
    private let deletePhotosUseCase: DeletePhotosUseCase

    init(
        getAllPhotosUseCase: GetAllPhotosUseCase = GetAllPhotosUseCaseImpl(
            sharedPhotoRepository: SharedPhotoRepositoryImpl()
        ),
        deletePhotosUseCase: DeletePhotosUseCase = DeletePhotosUseCaseImpl(
            sharedPhotoRepository: SharedPhotoRepositoryImpl(),
            photoRepository: PhotoRepositoryImpl()
        )
    ) {
        self.getAllPhotosUseCase = getAllPhotosUseCase
        self.deletePhotosUseCase = deletePhotosUseCase
    }

    func syncPhotos() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let loadedPhotos = try await getAllPhotosUseCase.execute(userId: APIConstants.userId)
            self.photos = loadedPhotos.filter { !$0.deleted }
                .sorted { $0.uploadedAt > $1.uploadedAt }
            self.errorMessage = nil
        } catch {
            self.errorMessage = "네트워크/파싱 오류: \(error.localizedDescription)"
        }
    }

    func deletePhotos(photoIds: [String]) async {
        guard !photoIds.isEmpty else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try await deletePhotosUseCase.execute(userId: APIConstants.userId, photoIds: photoIds)
            await syncPhotos()
            self.errorMessage = nil
        } catch {
            self.errorMessage = "삭제 실패: \(error.localizedDescription)"
        }
    }
}

private struct SharedAlbumViewModelKey: EnvironmentKey {
    static let defaultValue: SharedAlbumViewModel = SharedAlbumViewModel()
}

extension EnvironmentValues {
    var sharedAlbumViewModel: SharedAlbumViewModel {
        get { self[SharedAlbumViewModelKey.self] }
        set { self[SharedAlbumViewModelKey.self] = newValue }
    }
}
