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
        status = "Saving recording..."
        let recordedData = audioService.stopRecordingAndReturnData()
        saveAudioToFile(data: recordedData)
    }

    private func saveAudioToFile(data: Data) {
        let filename = getDocumentsDirectory().appendingPathComponent("recording_\(UUID().uuidString).aiff")

        // Create an audio file writer for AIFF format
        let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: false)!
        
        do {
            let audioFile = try AVAudioFile(forWriting: filename, settings: audioFormat.settings)
            
            // Convert Data to AVAudioPCMBuffer
            let pcmBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: UInt32(data.count) / audioFormat.streamDescription.pointee.mBytesPerFrame)!
            pcmBuffer.frameLength = pcmBuffer.frameCapacity
            data.copyBytes(to: pcmBuffer.floatChannelData![0], count: data.count)
            
            try audioFile.write(from: pcmBuffer)
            status = "Recording saved to: \(filename.lastPathComponent)"
            print("Recording saved to: \(filename.path)")
        } catch {
            status = "Failed to save recording."
            print("Failed to save recording: \(error.localizedDescription)")
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}