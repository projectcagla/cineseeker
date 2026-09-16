import Foundation
actor NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession
    private var cookies: [String: String] = [:]
    private var loaded = false
    init() {
        let config = URLSessionConfiguration.ephemeral
        config.httpShouldSetCookies = false
        config.timeoutIntervalForRequest = 30
        config.urlCache = URLCache(memoryCapacity: 16_000_000, diskCapacity: 80_000_000)
        session = URLSession(configuration: config, delegate: SameOriginRedirectDelegate(), delegateQueue: nil)
    }
    func data(_ endpoint: APIEndpoint) async throws -> Data {
        guard let base = AppConfiguration.baseURL else { throw NetworkError.configuration }
        if !loaded {
            if let data = try KeychainStore.read() { cookies = try JSONDecoder().decode([String: String].self, from: data) }
            loaded = true
        }
        var components = URLComponents(url: base.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)!
        components.queryItems = endpoint.query.sorted { $0.key < $1.key }.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components.url else { throw NetworkError.configuration }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.httpBody = endpoint.body
        if let expectedUser = endpoint.expectedUser { request.setValue(expectedUser, forHTTPHeaderField: "X-CineSeeker-User") }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(base.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/")), forHTTPHeaderField: "Origin")
        request.setValue(cookies.map { "\($0.key)=\($0.value)" }.joined(separator: "; "), forHTTPHeaderField: "Cookie")
        if !endpoint.tmdb { request.cachePolicy = .reloadIgnoringLocalCacheData }
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.url?.host == base.host else { throw NetworkError.invalidResponse }
        let headers = http.allHeaderFields.reduce(into: [String: String]()) { result, pair in result[String(describing: pair.key)] = String(describing: pair.value) }
        for cookie in HTTPCookie.cookies(withResponseHeaderFields: headers, for: url) {
            if cookie.expiresDate.map({ $0 <= Date() }) == true || cookie.value.isEmpty { cookies.removeValue(forKey: cookie.name) }
            else { cookies[cookie.name] = cookie.value }
        }
        try KeychainStore.save(JSONEncoder().encode(cookies))
        guard (200..<300).contains(http.statusCode) else {
            let message = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            throw NetworkError.server(http.statusCode, message?["error"] as? String ?? message?["message"] as? String ?? "İşlem tamamlanamadı. Lütfen tekrar deneyin.")
        }
        return data
    }
    func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        let data = try await data(endpoint)
        let decoder = JSONDecoder()
        if endpoint.tmdb { decoder.keyDecodingStrategy = .convertFromSnakeCase }
        return try decoder.decode(T.self, from: data)
    }
    func clearSession() throws { cookies = [:]; try KeychainStore.clear() }
}

final class SameOriginRedirectDelegate: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        guard let original = task.originalRequest?.url, let destination = request.url,
              original.host == destination.host, original.scheme == destination.scheme,
              original.port == destination.port else { return nil }
        return request
    }
}
