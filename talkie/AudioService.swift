
import Foundation
import AVFoundation

class AudioService: NSObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var audioSession: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }
    private var currentRecordingURL: URL?

    // Define recording settings for AIFF format
    private let recordingSettings: [String: Any] = [
        AVFormatIDKey: kAudioFormatLinearPCM,
        AVSampleRateKey: 16000,
        AVNumberOfChannelsKey: 1,
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsFloatKey: false,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]

    func startRecording() {
        do {
            try audioSession.setCategory(.record, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)

            let filename = getDocumentsDirectory().appendingPathComponent("recording_\(UUID().uuidString).aiff")
            currentRecordingURL = filename

            audioRecorder = try AVAudioRecorder(url: filename, settings: recordingSettings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            print("AudioService: Started recording to \(filename.lastPathComponent)")

        } catch {
            print("AudioService Error: Failed to start recording. Details: \(error.localizedDescription)")
        }
    }

    func stopRecordingAndReturnURL() -> URL? {
        audioRecorder?.stop()
        do {
            try audioSession.setActive(false)
        } catch {
            print("AudioService Error: Could not deactivate audio session. Details: \(error.localizedDescription)")
        }
        print("AudioService: Stopped recording.")
        return currentRecordingURL
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("AudioService: Recording finished successfully.")
        } else {
            print("AudioService: Recording failed or was interrupted.")
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("AudioService Error: Audio Recorder Encode Error: \(error?.localizedDescription ?? "Unknown error")")
    }
}
