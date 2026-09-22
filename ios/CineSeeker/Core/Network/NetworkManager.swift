import Foundation
actor NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession
    private let readToken: String?
    init(session: URLSession? = nil, readToken: String? = nil) {
        self.readToken = readToken
        let config = URLSessionConfiguration.default
        config.httpShouldSetCookies = false
        config.timeoutIntervalForRequest = 25
        config.urlCache = URLCache(memoryCapacity: 16_000_000, diskCapacity: 80_000_000, diskPath: "tmdb-catalog")
        self.session = session ?? URLSession(configuration: config, delegate: SameOriginRedirectDelegate(), delegateQueue: nil)
    }
    nonisolated static func makeRequest(_ endpoint: APIEndpoint, token: String?) throws -> URLRequest {
        guard let token, !token.isEmpty else { throw NetworkError.configuration }
        // A fixed origin and path-only endpoints prevent sending the token to another service.
        guard !endpoint.path.contains("://"), !endpoint.path.contains(".."), !endpoint.path.hasPrefix("/") else { throw NetworkError.invalidResponse }
        let base = URL(string: "https://api.themoviedb.org/3/")!
        var components = URLComponents(url: base.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)!
        let params = endpoint.query.merging(["language": "tr-TR"]) { requested, _ in requested }
        components.queryItems = params.sorted { $0.key < $1.key }.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components.url else { throw NetworkError.invalidResponse }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try Self.makeRequest(endpoint, token: readToken ?? AppConfiguration.tmdbReadToken)
        for attempt in 0...2 {
            try Task.checkCancellation()
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, http.url?.host == "api.themoviedb.org" else { throw NetworkError.invalidResponse }
            if http.statusCode == 429 && attempt < 2 {
                let delay = min(3, max(1, Double(http.value(forHTTPHeaderField: "Retry-After") ?? "1") ?? 1))
                try await Task.sleep(for: .seconds(delay)); continue
            }
            guard (200..<300).contains(http.statusCode) else {
                let message: String
                switch http.statusCode {
                case 401, 403: message = "Katalog erişimi doğrulanamadı. Lütfen uygulamanın güncel sürümünü kullandığından emin ol."
                case 404: message = "Bu içerik artık katalogda bulunmuyor."
                case 429: message = "Katalog şu anda yoğun. Biraz sonra tekrar dene."
                default: message = "Kataloğa ulaşılamadı. Lütfen tekrar dene."
                }
                throw NetworkError.server(http.statusCode, message)
            }
            let decoder = JSONDecoder(); decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        }
        throw NetworkError.invalidResponse
    }
}
final class SameOriginRedirectDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        guard let original = task.originalRequest?.url, let destination = request.url,
              original.host == destination.host, original.scheme == destination.scheme,
              original.port == destination.port else { return nil }
        return request
    }
}
