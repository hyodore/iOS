//
//  VideoPlayerViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI
import AVKit

@Observable
class VideoPlayerViewModel {
    var player: AVPlayer?
    var isLoading = true

    private let videoUrl: String

    init(videoUrl: String) {
        self.videoUrl = videoUrl
    }

    func loadVideo() {
        guard let url = URL(string: videoUrl),
              videoUrl.lowercased().hasPrefix("http://") || videoUrl.lowercased().hasPrefix("https://") else {
            isLoading = false
            return
        }

        player = AVPlayer(url: url)
    }

    func playVideo() {
        player?.play()
        isLoading = false
    }

    func pauseVideo() {
        player?.pause()
    }
}
