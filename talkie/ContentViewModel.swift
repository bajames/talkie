import Foundation
import Combine
import AVFoundation

class ContentViewModel: ObservableObject {
    @Published var isSessionActive = false
    @Published var status = "Welcome to Talkie"
    @Published var elapsedTime: TimeInterval = 0
    @Published var isProcessing = false

    private var audioService = AudioService()
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    func onAppear() {
        requestMicrophonePermission()
    }

    private func requestMicrophonePermission() {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    self.status = "Microphone access granted. Ready to record."
                } else {
                    self.status = "Microphone access denied. Please enable it in Settings."
                }
            }
        }
    }

    func startSession() {
        elapsedTime = 0
        isSessionActive = true
        status = "Recording..."
        audioService.startRecording()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }

    func stopSession() {
        isSessionActive = false
        isProcessing = true
        timer?.invalidate()
        timer = nil
        if let recordedURL = audioService.stopRecordingAndReturnURL() {
            status = "Recording saved to: \(recordedURL.lastPathComponent)"
            print("Recording saved to: \(recordedURL.path)")
        } else {
            status = "Failed to save recording."
        }
        isProcessing = false
    }
}