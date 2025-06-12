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
        self._viewModel = State (wrappedValue: VideoPlayerViewModel(videoUrl: videoUrl))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .overlay {
                        if viewModel.isBuffering {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                        } else if viewModel.showReplayButton {
                            Button(action: {
                                viewModel.replay()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                        }
                    }
            } else {
                if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else {
                    ProgressView("영상 로딩 중...")
                        .tint(.white)
                }
            }
        }
        .navigationTitle("이벤트 영상")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.player == nil {
                viewModel.loadVideo()
            }
        }
    }

    @ViewBuilder
    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            Text(message)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.8))
        )
    }
}
