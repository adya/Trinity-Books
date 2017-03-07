import Foundation

struct GoogleRequestManagerConfiguration : RequestManagerConfiguration {
    let baseUrl = "https://www.googleapis.com/books/v1/"
    let headers: [String : String]?

    init() {
        if let id = Bundle.main.bundleIdentifier {
            headers = ["User-Agent" : id]
        } else {
            headers = nil
            print("Failed to get Bundle ID")
        }
    }

}
