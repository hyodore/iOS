//
//  VideoPlayerView.swift
//  Hyodor
//
//  Created by 김상준 on 5/22/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoUrl: String
    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var error: Error? = nil

    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                        isLoading = false
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else if isLoading {
                ProgressView("영상 로딩 중...")
                    .scaleEffect(1.5)
                    .tint(.white)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)

                    Text("유효하지 않은 영상 URL입니다.")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("URL은 http:// 또는 https://로 시작해야 합니다.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.8))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            }
        }
        .navigationTitle("이벤트 영상")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadVideo()
        }
    }

    private func loadVideo() {
        guard let url = URL(string: videoUrl),
              videoUrl.lowercased().hasPrefix("http://") || videoUrl.lowercased().hasPrefix("https://") else {
            isLoading = false
            return
        }

        player = AVPlayer(url: url)
    }
}

