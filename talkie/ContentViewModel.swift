import Foundation
import Combine
import AVFoundation
import GoogleSignIn

class ContentViewModel: ObservableObject {
    @Published var isSessionActive = false
    @Published var status = "Welcome to Talkie"
    @Published var elapsedTime: TimeInterval = 0
    @Published var isProcessing = false
    @Published var isSignedIn = false

    private var audioService = AudioService()
    private var googleDriveService = GoogleDriveService()
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    func onAppear() {
        requestMicrophonePermission()
        self.isSignedIn = SharedUserDefaults.shared?.bool(forKey: SharedUserDefaults.isSignedInKey) ?? false
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
            googleDriveService.findOrCreateFolder(name: "Talkie") { [weak self] folderID, error in
                guard let self = self else { return }
                if let error = error {
                    self.status = "Error finding folder: \(error.localizedDescription)"
                    self.isProcessing = false
                    return
                }

                guard let folderID = folderID else {
                    self.status = "Could not find or create Talkie folder."
                    self.isProcessing = false
                    return
                }

                self.googleDriveService.uploadFile(name: recordedURL.lastPathComponent, fileURL: recordedURL, folderID: folderID) { fileID, error in
                    if let error = error {
                        self.status = "Error uploading file: \(error.localizedDescription)"
                    } else {
                        self.status = "Recording uploaded successfully!"
                    }
                    self.isProcessing = false
                }
            }
        } else {
            status = "Failed to save recording."
            isProcessing = false
        }
    }

    func signIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Could not find root view controller.")
            return
        }

        let additionalScopes = ["https://www.googleapis.com/auth/drive.file"]
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, hint: nil, additionalScopes: additionalScopes) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.status = "Sign-in error: \(error.localizedDescription)"
                SharedUserDefaults.shared?.set(false, forKey: SharedUserDefaults.isSignedInKey)
                return
            }
            guard let user = result?.user else {
                self.status = "Sign-in error: User not found."
                SharedUserDefaults.shared?.set(false, forKey: SharedUserDefaults.isSignedInKey)
                return
            }

            self.status = "Signed in as \(user.profile?.name ?? "Unknown")"
            self.isSignedIn = true
            self.googleDriveService = GoogleDriveService()
            SharedUserDefaults.shared?.set(true, forKey: SharedUserDefaults.isSignedInKey)
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isSignedIn = false
        status = "Signed out."
        SharedUserDefaults.shared?.set(false, forKey: SharedUserDefaults.isSignedInKey)
    }
}