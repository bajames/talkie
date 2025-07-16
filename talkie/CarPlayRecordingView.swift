import SwiftUI

struct CarPlayRecordingView: View {
    @ObservedObject var viewModel: CarPlayViewModel

    var body: some View {
        VStack {
            Text(viewModel.status)
                .font(.title)
            Button(action: {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }) {
                Text(viewModel.isRecording ? "Stop" : "Record")
                    .font(.title)
                    .padding()
                    .background(viewModel.isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
