//
//  TossAudioPlaybackCard.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI

struct ASAudioPlaybackCard: View {
    let audioRecorder: AudioRecorder
    @State private var isPlaying = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 60, height: 60)

                    Image(systemName: "checkmark")
                        .font(.title2)
                        .foregroundColor(.green)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("녹음 완료")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("음성 메모가 저장되었어요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 12) {
                    Button(action: {
                        if isPlaying {
                            audioRecorder.stopPlayback()
                        } else {
                            Task{ await audioRecorder.playRecording()}
                        }
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }

                    Button(action: {
                        audioRecorder.deleteRecording()
                    }) {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(.red)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

#Preview {
    ASAudioPlaybackCard(audioRecorder: AudioRecorder())
        .padding()
}
