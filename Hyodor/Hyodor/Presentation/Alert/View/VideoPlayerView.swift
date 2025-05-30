//
//  VideoPlayerView.swift
//  Hyodor
//
//  Created by 김상준 on 5/22/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @State private var viewModel: VideoPlayerViewModel

    init(videoUrl: String) {
        self._viewModel = State(initialValue: VideoPlayerViewModel(videoUrl: videoUrl))
    }

    var body: some View {
        ZStack {
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .ignoresSafeArea()
                    .onAppear {
                        viewModel.playVideo()
                    }
                    .onDisappear {
                        viewModel.pauseVideo()
                    }
            } else if viewModel.isLoading {
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
            viewModel.loadVideo()
        }
    }
}

#Preview {
    VideoPlayerView(videoUrl: "https://example.com/video.mp4")
}
