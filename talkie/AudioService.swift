
import Foundation
import AVFoundation

class AudioService {
    private var audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    private var audioConverter: AVAudioConverter?
    private var audioSession: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }
    private var accumulatedAudioData = Data()

    // Define the target format required by the Gemini API
    private let geminiFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: false)! // 16kHz mono

    init() {
        audioEngine.attach(audioPlayerNode)
        let mixer = audioEngine.mainMixerNode
        // Connect the audioPlayerNode to the mixer using the geminiFormat
        audioEngine.connect(audioPlayerNode, to: mixer, format: geminiFormat)
    }

    func startRecording() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)
        } catch {
            print("AudioService Error: Failed to set up audio session. Details: \(error.localizedDescription)")
            return
        }

        let inputNode = audioEngine.inputNode
        let hardwareFormat = inputNode.outputFormat(forBus: 0)

        // Initialize the audio converter if needed
        if hardwareFormat != geminiFormat {
            audioConverter = AVAudioConverter(from: hardwareFormat, to: geminiFormat)
            guard audioConverter != nil else {
                print("AudioService Error: Failed to create audio converter.")
                return
            }
        } else {
            audioConverter = nil // No conversion needed
        }

        // Ensure the engine is started before installing the tap
        if !audioEngine.isRunning {
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch {
                print("AudioService Error: Could not start audio engine. Details: \(error.localizedDescription)")
                return
            }
        }

        // Clear any previously accumulated data
        accumulatedAudioData = Data()

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: hardwareFormat) { (buffer, when) in
            self.convertAndProcess(buffer: buffer) { data in
                self.accumulatedAudioData.append(data)
            }
        }
    }

    private func convertAndProcess(buffer: AVAudioPCMBuffer, completion: @escaping (Data) -> Void) {
        if let converter = audioConverter {
            // Create a buffer to hold the converted audio.
            let convertedBuffer = AVAudioPCMBuffer(pcmFormat: geminiFormat, frameCapacity: AVAudioFrameCount(geminiFormat.sampleRate) * buffer.frameLength / AVAudioFrameCount(buffer.format.sampleRate))!

            var error: NSError? = nil
            let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                outStatus.pointee = .haveData
                return buffer
            }

            // Perform the conversion
            converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputBlock)

            if let error = error {
                print("AudioService Error: Conversion failed - \(error.localizedDescription)")
                return
            }

            if let data = self.audioBufferToData(buffer: convertedBuffer) {
                completion(data)
            }
        } else {
            // No conversion needed, use original buffer
            if let data = self.audioBufferToData(buffer: buffer) {
                completion(data)
            }
        }
    }

    func stopRecordingAndReturnData() -> Data {
        audioEngine.inputNode.removeTap(onBus: 0)

        // Only deactivate audio session if no playback is scheduled
        if !audioPlayerNode.isPlaying {
            do {
                try audioSession.setActive(false)
            } catch {
                print("AudioService Error: Could not deactivate audio session. Details: \(error.localizedDescription)")
            }
        }
        return accumulatedAudioData
    }

    func playAudio(data: Data) {
        guard let pcmBuffer = dataToPCMBuffer(data: data, format: geminiFormat) else {
            print("AudioService Error: Failed to create PCM buffer for playback.")
            return
        }

        audioPlayerNode.scheduleBuffer(pcmBuffer)
        if !audioPlayerNode.isPlaying {
            audioPlayerNode.play()
        }
    }

    private func audioBufferToData(buffer: AVAudioPCMBuffer) -> Data? {
        guard let channelData = buffer.floatChannelData else { return nil }
        let channelDataPointer = channelData.pointee
        let dataSize = Int(buffer.frameLength) * MemoryLayout<Float>.size

        return Data(bytes: channelDataPointer, count: dataSize)
    }

    private func dataToPCMBuffer(data: Data, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let frameCapacity = UInt32(data.count) / format.streamDescription.pointee.mBytesPerFrame
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else {
            return nil
        }
        pcmBuffer.frameLength = pcmBuffer.frameCapacity

        let audioBuffer = pcmBuffer.audioBufferList.pointee.mBuffers
        guard let bufferPointer = audioBuffer.mData else {
            return nil
        }

        data.copyBytes(to: bufferPointer.bindMemory(to: UInt8.self, capacity: data.count), count: data.count)

        return pcmBuffer
    }
}
