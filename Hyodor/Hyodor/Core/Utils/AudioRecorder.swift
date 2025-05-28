//
//  AudioRecorder.swift
//  Hyodor
//
//  Created by 김상준 on 5/28/25.
//

import Foundation
import AVFoundation

@Observable
class AudioRecorder: NSObject {
    var isRecording = false
    var hasPermission = false
    var showingPermissionAlert = false
    var recordingURL: URL?
    var recordingTime = "00:00"

    var isPlaying = false
    var playbackTime = "00:00"

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var playbackTimer: Timer?
    private var startTime: Date?
    private var playbackStartTime: Date?

    override init() {
        super.init()
    }

    func playRecording() async {
        guard let url = recordingURL else {
            print("재생할 파일이 없습니다")
            return
        }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()

            await MainActor.run {
                isPlaying = true
                playbackStartTime = Date()
                startPlaybackTimer()
            }

            print("🔊 재생 시작: \(url.lastPathComponent)")
        } catch {
            print("재생 실패: \(error.localizedDescription)")
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        stopPlaybackTimer()
        playbackTime = "00:00"

        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("오디오 세션 비활성화 실패: \(error.localizedDescription)")
        }

        print("🔇 재생 중지")
    }

    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updatePlaybackTime()
        }
    }

    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    private func updatePlaybackTime() {
        guard let player = audioPlayer else { return }
        let currentTime = player.currentTime
        let minutes = Int(currentTime) / 60
        let seconds = Int(currentTime) % 60
        playbackTime = String(format: "%02d:%02d", minutes, seconds)
    }

    func requestPermission() async {
        if #available(iOS 17.0, *) {
            let granted = await AVAudioApplication.requestRecordPermission()
            await MainActor.run {
                hasPermission = granted
                if !granted {
                    showingPermissionAlert = true
                }
            }
        } else {
            let audioSession = AVAudioSession.sharedInstance()
            switch audioSession.recordPermission {
            case .granted:
                await MainActor.run { hasPermission = true }
            case .denied:
                await MainActor.run {
                    hasPermission = false
                    showingPermissionAlert = true
                }
            case .undetermined:
                let granted = await withCheckedContinuation { continuation in
                    audioSession.requestRecordPermission { granted in
                        continuation.resume(returning: granted)
                    }
                }
                await MainActor.run {
                    hasPermission = granted
                    if !granted { showingPermissionAlert = true }
                }
            @unknown default:
                await MainActor.run { hasPermission = false }
            }
        }
    }

    func startRecording() async {
        guard hasPermission else {
            await MainActor.run { showingPermissionAlert = true }
            return
        }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetooth]
            )
            try audioSession.setActive(true)

            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "voice_memo_\(Date().timeIntervalSince1970).m4a"
            recordingURL = documentsPath.appendingPathComponent(fileName)

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 128000
            ]

            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            await MainActor.run {
                isRecording = true
                startTime = Date()
                startTimer()
            }

        } catch {
            print("녹음 시작 실패: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        stopTimer()

        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("오디오 세션 비활성화 실패: \(error.localizedDescription)")
        }
    }

    func deleteRecording() {
        stopPlayback()
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
            recordingURL = nil
        }
    }

    func cleanup() {
        stopRecording()
        stopPlayback()
        deleteRecording()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateRecordingTime()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateRecordingTime() {
        guard let startTime = startTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        recordingTime = String(format: "%02d:%02d", minutes, seconds)
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("녹음 실패")
            recordingURL = nil
        }
    }
}

extension AudioRecorder: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.stopPlayback()
        }
    }
}
