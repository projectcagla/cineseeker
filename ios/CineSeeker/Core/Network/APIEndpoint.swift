import Foundation
struct APIEndpoint: Sendable {
    let path: String
    var query: [String: String] = [:]
}
enum AppConfiguration {
    static var tmdbReadToken: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "TMDB_READ_TOKEN") as? String else { return nil }
        let token = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return token.isEmpty || token.contains("$(") || token == "YOUR_TMDB_READ_ACCESS_TOKEN" ? nil : token
    }
}
