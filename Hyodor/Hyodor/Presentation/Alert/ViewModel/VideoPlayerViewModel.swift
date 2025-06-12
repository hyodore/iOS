//
//  VideoPlayerViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI
import AVKit
import Combine

@Observable
class VideoPlayerViewModel {
    var player: AVPlayer?
    var isBuffering = true
    var showReplayButton = false
    var errorMessage: String?

    private let videoUrl: String
    private var cancellables = Set<AnyCancellable>()

    init(videoUrl: String) {
        self.videoUrl = videoUrl
    }

    func loadVideo() {
        guard let url = URL(string: videoUrl),
              videoUrl.lowercased().hasPrefix("http://") || videoUrl.lowercased().hasPrefix("https://") else {
            errorMessage = "유효하지 않은 영상 URL입니다."
            isBuffering = false
            return
        }

        player = AVPlayer(url: url)
        setupPlayerObservers() 
        player?.play()
    }

    private func setupPlayerObservers() {
        player?.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .playing:
                    self?.isBuffering = false
                case .paused:
                    break
                case .waitingToPlayAtSpecifiedRate:
                    self?.isBuffering = true
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)

        player?.currentItem?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .failed {
                    self?.errorMessage = "영상을 불러오는 데 실패했습니다. 네트워크 연결을 확인해주세요."
                    self?.isBuffering = false
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.showReplayButton = true
            }
            .store(in: &cancellables)
    }

    func replay() {
        showReplayButton = false
        player?.seek(to: .zero)
        player?.play()
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
