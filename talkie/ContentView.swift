
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            Spacer()

            Text(viewModel.status)
                .font(.title)
                .padding()

            Spacer()

            if viewModel.isProcessing {
                ProgressView()
                    .padding()
            }

            if viewModel.isSessionActive {
                Text(formatTime(viewModel.elapsedTime))
                    .font(.largeTitle)
                    .padding()
                Button(action: {
                    viewModel.stopSession()
                }) {
                    Text("Stop Talking")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            } else {
                Button(action: {
                    viewModel.startSession()
                }) {
                    Text("Start Talking")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
