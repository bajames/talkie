
import Foundation

enum APIKey {
    static var gemini: String {
        guard let path = Bundle.main.path(forResource: "credentials", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["GeminiAPIKey"] as? String else {
            fatalError("Could not find or parse credentials.plist. Please make sure it exists and contains your GeminiAPIKey.")
        }
        return key
    }
}
