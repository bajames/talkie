
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

            if viewModel.isSessionActive {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
