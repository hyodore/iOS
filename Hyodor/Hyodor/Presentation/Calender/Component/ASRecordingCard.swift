//
//  TossRecordingCard.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI

struct ASRecordingCard: View {
    let audioRecorder: AudioRecorder
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 60, height: 60)

                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: recordingTime)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("녹음 중...")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(formatTime(recordingTime))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }

                Spacer()

                Button(action: {
                    audioRecorder.stopRecording()
                    timer?.invalidate()
                    timer = nil
                }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.red)
                        )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.3), lineWidth: 2)
                )
        )
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, milliseconds)
    }
}

#Preview {
    ASRecordingCard(audioRecorder: AudioRecorder())
        .padding()
}
