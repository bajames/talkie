import Foundation
import Combine
import GoogleSignIn

class CarPlayViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var isRecording = false
    @Published var status = "Welcome to Talkie"

    private var audioService = AudioService()
    private var googleDriveService = GoogleDriveService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        updateSignInState()
    }

    func updateSignInState() {
        self.isSignedIn = SharedUserDefaults.shared?.bool(forKey: SharedUserDefaults.isSignedInKey) ?? false
        self.googleDriveService = GoogleDriveService()
        if !self.isSignedIn {
            self.status = "Please sign in on your phone to start recording."
        } else {
            self.status = "Ready to record."
        }
    }

    func startRecording() {
        isRecording = true
        status = "Recording..."
        audioService.startRecording()
    }

    func stopRecording() {
        isRecording = false
        status = "Uploading..."
        if let recordedURL = audioService.stopRecordingAndReturnURL() {
            googleDriveService.findOrCreateFolder(name: "Talkie") { [weak self] folderID, error in
                guard let self = self else { return }
                if let error = error {
                    self.status = "Error finding folder: \(error.localizedDescription)"
                    return
                }

                guard let folderID = folderID else {
                    self.status = "Could not find or create Talkie folder."
                    return
                }

                self.googleDriveService.uploadFile(name: recordedURL.lastPathComponent, fileURL: recordedURL, folderID: folderID) { fileID, error in
                    if let error = error {
                        self.status = "Error uploading file: \(error.localizedDescription)"
                    } else {
                        self.status = "Recording uploaded successfully!"
                    }
                }
            }
        } else {
            status = "Failed to save recording."
        }
    }
}
