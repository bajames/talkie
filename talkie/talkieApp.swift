
import SwiftUI
import GoogleSignIn

@main
struct talkieApp: App {

    init() {
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: "522475355986-lrailc79pvn70pcj71eesq62jk13irji.apps.googleusercontent.com"
        )
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
