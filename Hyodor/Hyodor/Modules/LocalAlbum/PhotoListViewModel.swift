//
//  PhotoListViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/23/25.
//

// MARK: - 뷰모델
import SwiftUI
import Photos

class PhotoListViewModel: ObservableObject {
    // 서비스
    private let uploadService: GalleryUploadServiceProtocol
    // 업로드된 사진 관리자
    private let uploadedPhotoManager = UploadedPhotoManager()

    // 저장된 업로드 정보 로드
    private func loadUploadedPhotos() {
        _ = uploadedPhotoManager.getAllUploadedPhotos()

        // 사진첩에서 가져온 에셋과 저장된 업로드 정보 매칭
        for (index, asset) in photoAssets.enumerated() {
            if uploadedPhotoManager.isPhotoUploaded(assetId: asset.id) {
                photoAssets[index].isUploaded = true
            }
        }
    }

    // 상태
    @Published var photoAssets: [PhotoAssetModel] = []
    @Published var isUploading = false
    @Published var showingPermissionAlert = false
    @Published var showingDuplicateAlert = false
    @Published var showingUploadSuccess = false
    @Published var uploadSuccessCount = 0

    // 사용자 ID (실제 앱에서는 인증 시스템에서 가져와야 함)
    private let userId = "user123"

    // 초기화
    init(uploadService: GalleryUploadServiceProtocol = GalleryUploadService()) {
        self.uploadService = uploadService
        loadUploadedPhotos()
    }

    // MARK: - 사진첩 접근 권한 요청
    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    print("사진첩 접근 권한 획득")
                    self?.fetchPhotos()
                case .denied, .restricted:
                    print("사진첩 접근 권한 거부됨")
                    self?.showingPermissionAlert = true
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

        var assets: [PhotoAssetModel] = []
        fetchResult.enumerateObjects { asset, _, _ in
            // 업로드 상태 확인
            let isUploaded = self.uploadedPhotoManager.isPhotoUploaded(assetId: asset.localIdentifier)
            assets.append(PhotoAssetModel(asset: asset, isSelected: false, isUploaded: isUploaded))
        }

        // 메인 스레드에서 UI 업데이트
        DispatchQueue.main.async {
            self.photoAssets = assets
            print("가져온 사진 수: \(assets.count)")
        }
    }

    // 사진 탭 처리
    func handleTap(assetId: String) {
        guard let index = photoAssets.firstIndex(where: { $0.id == assetId }) else { return }

        // 업로드된 사진인지 확인
        if photoAssets[index].isUploaded || uploadedPhotoManager.isPhotoUploaded(assetId: assetId) {
            showingDuplicateAlert = true // 이미 업로드된 경우 알림
        } else {
            // 선택 상태 토글
            photoAssets[index].isSelected.toggle()
        }
    }

    // 선택된 사진 수
    var selectedCount: Int {
        photoAssets.filter { $0.isSelected }.count
    }

    // 선택된 사진 여부
    var hasSelectedPhotos: Bool {
        selectedCount > 0
    }

    // MARK: - 업로드 처리
    func uploadSelectedPhotos() {
        guard hasSelectedPhotos, !isUploading else { return }

        // 선택된 사진 중 이미 업로드된 사진이 있는지 확인
        let selectedAssetModels = photoAssets.filter { $0.isSelected }
        let alreadyUploadedAssets = selectedAssetModels.filter {
            uploadedPhotoManager.isPhotoUploaded(assetId: $0.id)
        }

        // 이미 업로드된 사진이 있으면 경고
        if !alreadyUploadedAssets.isEmpty {
            // 이미 업로드된 사진 선택 해제
            for assetId in alreadyUploadedAssets.map({ $0.id }) {
                if let index = photoAssets.firstIndex(where: { $0.id == assetId }) {
                    photoAssets[index].isSelected = false
                }
            }

            // 경고 메시지 표시
            showingDuplicateAlert = true
            return
        }

        isUploading = true

        // 기존 업로드 로직...
    }

    // S3에 이미지 업로드
    private func uploadImagesToS3(images: [UIImage], presignedURLs: [PresignedURLResponse], selectedAssets: [PHAsset]) {
        let uploadGroup = DispatchGroup()
        var successfulUploads: [UploadCompleteRequest.UploadedPhotoInfo] = []

        for (index, presignedURL) in presignedURLs.enumerated() {
            guard index < images.count else { continue }

            uploadGroup.enter()
            uploadService.uploadImageToS3(image: images[index], presignedURL: presignedURL) { [weak self] success in
                guard self != nil else { return }

                if success {
                    // ISO 8601 형식의 현재 시간
                    let dateFormatter = ISO8601DateFormatter()
                    let uploadTime = dateFormatter.string(from: Date())

                    // 성공한 업로드 정보 저장
                    let uploadInfo = UploadCompleteRequest.UploadedPhotoInfo(
                        photoId: presignedURL.photoId,
                        photoUrl: presignedURL.photoUrl,
                        uploadAt: uploadTime
                    )

                    DispatchQueue.main.async {
                        successfulUploads.append(uploadInfo)
                    }
                }
                uploadGroup.leave()
            }
        }

        uploadGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            // 4. 업로드 완료 알림
            if !successfulUploads.isEmpty {
                self.notifyUploadComplete(
                    successfulUploads: successfulUploads,
                    presignedURLs: presignedURLs,
                    selectedAssets: selectedAssets
                )
            } else {
                DispatchQueue.main.async {
                    print("업로드 실패: 성공적으로 업로드된 이미지 없음")
                    self.isUploading = false
                    // 에러 처리 추가
                }
            }
        }
    }

    // 업로드 완료 알림
    private func notifyUploadComplete(successfulUploads: [UploadCompleteRequest.UploadedPhotoInfo], presignedURLs: [PresignedURLResponse], selectedAssets: [PHAsset]) {
        uploadService.notifyUploadComplete(userId: userId, uploadedPhotos: successfulUploads) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("업로드 완료 알림 성공: \(response.syncedAt)")

                    // 업로드된 에셋 표시 업데이트
                    let uploadedPhotoIds = Set(response.newPhoto.map { $0.photoId })
                    var newUploadedPhotos: [UploadedPhotoInfo] = []

                    for (index, asset) in selectedAssets.enumerated() {
                        if index < presignedURLs.count,
                           uploadedPhotoIds.contains(presignedURLs[index].photoId) {

                            // 뷰모델 상태 업데이트
                            if let assetIndex = self.photoAssets.firstIndex(where: { $0.id == asset.localIdentifier }) {
                                self.photoAssets[assetIndex].isUploaded = true
                                self.photoAssets[assetIndex].isSelected = false
                            }

                            // 영구 저장소에 업로드 정보 저장
                            let uploadedPhoto = UploadedPhotoInfo(
                                id: asset.localIdentifier,
                                photoId: presignedURLs[index].photoId,
                                photoUrl: presignedURLs[index].photoUrl,
                                uploadedAt: Date()
                            )
                            newUploadedPhotos.append(uploadedPhoto)
                        }
                    }

                    // 업로드된 사진 정보 저장
                    self.uploadedPhotoManager.saveUploadedPhotos(newUploadedPhotos)

                    self.uploadSuccessCount = uploadedPhotoIds.count
                    self.isUploading = false
                    self.showingUploadSuccess = true

                case .failure(let error):
                    print("업로드 완료 알림 실패: \(error.localizedDescription)")
                    self.isUploading = false
                    // 에러 처리 추가
                }
            }
        }
    }

    // 이미지 파일 확장자 결정 함수
    private func getImageFileExtension(from asset: PHAsset) -> String {
        // UTI를 확인하여 확장자 결정
        if let uti = asset.value(forKey: "uniformTypeIdentifier") as? String {
            if uti == "public.png" {
                return "png"
            }
        }
        return "jpg" // 기본값은 jpg
    }
}
