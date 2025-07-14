import SwiftUI
import GoogleSignIn

@main
struct talkieApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if connectingSceneSession.role == .carTemplateApplication {
            let scene = UISceneConfiguration(name: "CarPlay", sessionRole: connectingSceneSession.role)
            scene.delegateClass = CarPlaySceneDelegate.self
            return scene
        } else {
            let scene = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
            scene.delegateClass = SceneDelegate.self
            return scene
        }
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
}
