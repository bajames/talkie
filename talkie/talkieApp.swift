
import SwiftUI
import GoogleSignIn

@main
struct talkieApp: App {

    init() {
        let configuration = GIDConfiguration(
            clientID: "522475355986-lrailc79pvn70pcj71eesq62jk13irji.apps.googleusercontent.com"
        )
        // Add the Drive scope
        configuration.scopes.append("https://www.googleapis.com/auth/drive.file")
        GIDSignIn.sharedInstance.configuration = configuration
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
