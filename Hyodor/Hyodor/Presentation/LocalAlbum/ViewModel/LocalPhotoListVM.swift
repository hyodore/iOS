//
//  PhotoListViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

import SwiftUI
import Photos

@Observable
class LocalPhotoListVM {
    private let photoRepository: LocalPhotoRecordRepository

    private let photoUploadUseCase: PhotoUploadUseCase

    var photoAssets: [PhotoAssetModel] = []
    var isUploading = false
    var activeAlert: AlertType?

    enum AlertType: Identifiable {
        case permission
        case duplicate
        case uploadSuccess(count: Int)
        case uploadFailure(error: String)

        var id: String {
            switch self {
            case .permission: return "permission"
            case .duplicate: return "duplicate"
            case .uploadSuccess: return "uploadSuccess"
            case .uploadFailure: return "uploadFailure"
            }
        }
    }

    init(
        photoRepository: LocalPhotoRecordRepository
 = LocalPhotoRecordRepositoryImpl(),
        photoUploadUseCase: PhotoUploadUseCase = PhotoUploadUseCaseImpl()
    ) {
        self.photoRepository = photoRepository
        self.photoUploadUseCase = photoUploadUseCase
    }

    var hasSelectedPhotos: Bool {
        photoAssets.contains(where: { $0.isSelected })
    }

    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self?.fetchPhotos()
                case .denied, .restricted:
                    self?.activeAlert = .permission
                default:
                    break
                }
            }
        }
    }

    func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var assets: [PhotoAssetModel] = []
        fetchResult.enumerateObjects { asset, _, _ in
            let isUploaded = self.photoRepository.checkIsUploaded(assetId: asset.localIdentifier)
            assets.append(PhotoAssetModel(asset: asset, isSelected: false, isUploaded: isUploaded))
        }

        DispatchQueue.main.async {
            self.photoAssets = assets
        }
    }

    func handleTap(assetId: String) {
        guard let index = photoAssets.firstIndex(where: { $0.id == assetId }) else { return }

        if photoAssets[index].isUploaded {
            activeAlert = .duplicate
        } else {
            photoAssets[index].isSelected.toggle()
        }
    }

    func uploadSelectedPhotos(onComplete: ((SyncResponseDTO) -> Void)? = nil) async {
        guard hasSelectedPhotos, !isUploading else { return }

        isUploading = true
        let selectedAssets = photoAssets.filter { $0.isSelected }.map { $0.asset }

        let result = await photoUploadUseCase.execute(assets: selectedAssets)

        switch result {
        case .success(let response, let count):
            self.activeAlert = .uploadSuccess(count: count)
            self.refreshUploadedStatus()
            onComplete?(response)
        case .failure(let error):
            self.activeAlert = .uploadFailure(error: error.localizedDescription)
        }

        isUploading = false
    }

    private func refreshUploadedStatus() {
        for index in photoAssets.indices {
            if !photoAssets[index].isUploaded && photoRepository.checkIsUploaded(assetId: photoAssets[index].id) {
                photoAssets[index].isUploaded = true
                photoAssets[index].isSelected = false
            }
        }
    }
}
