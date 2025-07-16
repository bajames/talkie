import Foundation

struct SharedUserDefaults {
    static let suiteName = "group.com.example.talkie"
    static let isSignedInKey = "isSignedIn"

    static var shared: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }
}
