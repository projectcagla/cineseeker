import Foundation
struct APIEndpoint: Sendable {
    let path: String
    var query: [String: String] = [:]
    var method = "GET"
    var body: Data? = nil
    var tmdb = false
    var expectedUser: String? = nil
    static func catalog(_ action: String, media: MediaType = .movie, params: [String: String] = [:]) -> Self {
        .init(path: "api/mobile/catalog", query: params.merging(["action": action, "media": media.rawValue]) { _, new in new }, tmdb: true)
    }
}
enum AppConfiguration {
    static var baseURL: URL? {
        guard let string = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              let url = URL(string: string), url.scheme == "https", url.host != nil, !string.contains("$(") else { return nil }
        return url
    }
}
