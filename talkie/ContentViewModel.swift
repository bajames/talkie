import Foundation
import Combine
import AVFoundation

class ContentViewModel: ObservableObject {
    @Published var isSessionActive = false
    @Published var status = "Welcome to Talkie"

    private var audioService = AudioService()
    private var cancellables = Set<AnyCancellable>()

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
        isSessionActive = true
        status = "Recording..."
        audioService.startRecording()
    }

    func stopSession() {
        isSessionActive = false
        if let recordedURL = audioService.stopRecordingAndReturnURL() {
            status = "Recording saved to: \(recordedURL.lastPathComponent)"
            print("Recording saved to: \(recordedURL.path)")
        } else {
            status = "Failed to save recording."
        }
    }
}