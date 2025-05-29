//
//  TossAudioInput.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI

struct TossAudioInput: View {
    let viewModel: AddEventViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("음성 메모를 추가하시겠어요?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("목소리로 더 자세한 내용을 남겨보세요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if viewModel.audioRecorder.isRecording {
                TossRecordingCard(audioRecorder: viewModel.audioRecorder)
            } else if viewModel.audioRecorder.recordingURL != nil {
                TossAudioPlaybackCard(audioRecorder: viewModel.audioRecorder)
            } else {
                Button(action: {
                    Task {
                        await viewModel.audioRecorder.startRecording()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "mic.fill")
                            .font(.title2)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("음성 메모 녹음하기")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)

                            Text("탭해서 녹음을 시작하세요")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .disabled(!viewModel.audioRecorder.hasPermission)
                .opacity(viewModel.audioRecorder.hasPermission ? 1.0 : 0.6)
            }
        }
    }
}
