import CarPlay
import Combine

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {

    var interfaceController: CPInterfaceController?
    private var cancellables = Set<AnyCancellable>()
    private var viewModel = CarPlayViewModel()

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController

        viewModel.$isSignedIn.sink { [weak self] isSignedIn in
            self?.updateRootTemplate(isSignedIn: isSignedIn)
        }.store(in: &cancellables)

        viewModel.$isRecording.sink { [weak self] _ in
            self?.updateRecordingTemplate()
        }.store(in: &cancellables)

        viewModel.updateSignInState()
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }

    private func updateRootTemplate(isSignedIn: Bool) {
        if isSignedIn {
            updateRecordingTemplate()
        } else {
            let item = CPListItem(text: "Please sign in", detailText: "Open the app on your phone to sign in.")
            let section = CPListSection(items: [item])
            let listTemplate = CPListTemplate(title: "Talkie", sections: [section])
            interfaceController?.setRootTemplate(listTemplate, animated: true)
        }
    }

    private func updateRecordingTemplate() {
        let title = viewModel.isRecording ? "Recording..." : "Ready to Record"
        let recordButton = CPGridButton(title: viewModel.isRecording ? "Stop" : "Record", image: UIImage(systemName: "mic.fill")!) { [weak self] _ in
            self?.viewModel.isRecording ?? false ? self?.viewModel.stopRecording() : self?.viewModel.startRecording()
            self?.updateRecordingTemplate()
        }
        let gridTemplate = CPGridTemplate(title: title, gridButtons: [recordButton])
        interfaceController?.setRootTemplate(gridTemplate, animated: true)
    }
}
