import XCTest
import SwiftData
@testable import CineSeeker
final class CineSeekerTests: XCTestCase {
    func testMovieAndTVDecoding() throws {
        let decoder = JSONDecoder(); decoder.keyDecodingStrategy = .convertFromSnakeCase
        let movie = try decoder.decode(Movie.self, from: Data(#"{"id":42,"title":"Film","media_type":"movie","vote_average":8.2,"release_date":"2024-01-01"}"#.utf8))
        let tv = try decoder.decode(Movie.self, from: Data(#"{"id":42,"name":"Dizi","media_type":"tv","first_air_date":"2025-01-01"}"#.utf8))
        XCTAssertNotEqual(movie.key, tv.key); XCTAssertEqual(tv.displayTitle, "Dizi"); XCTAssertEqual(movie.year, "2024")
    }
    @MainActor func testOfflinePersistenceAndAccountIsolation() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SavedTitle.self, SavedProvider.self, PendingMutation.self, LocalMetadata.self, configurations: config)
        let store = StorageManager(container: container)
        let movie = Movie(id: 12, title: "Film", mediaType: .movie)
        let tv = Movie(id: 12, name: "Dizi", mediaType: .tv)
        store.save(movie, status: .want); store.save(tv, status: .watching, rating: 9)
        XCTAssertEqual(store.titles.count, 2)
        let reopened = StorageManager(container: container)
        XCTAssertEqual(reopened.item(tv)?.rating, 9)
        try reopened.switchOwner("another-user")
        XCTAssertTrue(reopened.titles.isEmpty)
        try reopened.switchOwner("guest")
        reopened.remove(movie)
        XCTAssertNil(reopened.item(movie)); XCTAssertNotNil(reopened.item(tv))
        reopened.save(tv, status: .watched, rating: 11)
        XCTAssertEqual(reopened.item(tv)?.rating, 9)
        reopened.save(tv, status: .watched)
        XCTAssertNil(reopened.item(tv)?.rating)
    }
    @MainActor func testSearchHistoryAndExport() throws {
        let container = try ModelContainer(for: SavedTitle.self, SavedProvider.self, PendingMutation.self, LocalMetadata.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let store = StorageManager(container: container)
        store.remember("  Dune  "); store.remember("Dune")
        XCTAssertEqual(store.recentSearches, ["Dune"])
        let export = try XCTUnwrap(JSONSerialization.jsonObject(with: store.localExport()) as? [String: Any])
        XCTAssertNotNil(export["watchlist"]); XCTAssertEqual(export["searches"] as? [String], ["Dune"])
        store.clearHistory(); XCTAssertTrue(store.recentSearches.isEmpty)
    }
    @MainActor func testLocalResetAndNoSyncQueue() throws {
        let container = try ModelContainer(for: SavedTitle.self, SavedProvider.self, PendingMutation.self, LocalMetadata.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let store = StorageManager(container: container)
        store.save(Movie(id: 19, title: "Kayıt", mediaType: .movie), status: .watched, rating: 8)
        store.toggle(Provider(providerId: 8, providerName: "Netflix", logoPath: "/logo.jpg"))
        store.remember("Dune")
        XCTAssertTrue(try store.context.fetch(FetchDescriptor<PendingMutation>()).isEmpty)
        try store.resetLocalData()
        let reopened = StorageManager(container: container)
        XCTAssertTrue(reopened.titles.isEmpty)
        XCTAssertTrue(reopened.selected.isEmpty)
        XCTAssertTrue(reopened.recentSearches.isEmpty)
    }
    func testTMDBRequestUsesBearerHeaderAndFixedOrigin() throws {
        let request = try NetworkManager.makeRequest(.init(path: "search/movie", query: ["query": "Aşk & Film"]), token: "test-token")
        XCTAssertEqual(request.url?.host, "api.themoviedb.org")
        XCTAssertEqual(request.url?.path, "/3/search/movie")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
        XCTAssertFalse(request.url!.absoluteString.contains("test-token"))
        let params = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!.queryItems!
        XCTAssertTrue(params.contains(URLQueryItem(name: "query", value: "Aşk & Film")))
        XCTAssertThrowsError(try NetworkManager.makeRequest(.init(path: "movie/1"), token: nil))
        XCTAssertThrowsError(try NetworkManager.makeRequest(.init(path: "https://example.com"), token: "test-token"))
        XCTAssertThrowsError(try NetworkManager.makeRequest(.init(path: "../secret"), token: "test-token"))
    }
    func testNewReleasesUseReleaseDatesAndSubscriptionsUseOR() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let movie = LiveCatalogRepository.discoverQuery(media: .movie, mode: .arrivals, providers: [], page: 1, now: date)
        let tv = LiveCatalogRepository.discoverQuery(media: .tv, mode: .arrivals, providers: [], page: 1, now: date)
        XCTAssertEqual(movie["sort_by"], "primary_release_date.desc")
        XCTAssertEqual(tv["sort_by"], "first_air_date.desc")
        XCTAssertEqual(movie["primary_release_date.lte"], "2023-11-14")
        XCTAssertEqual(movie["watch_region"], "TR")
        XCTAssertNil(tv["primary_release_date.lte"])
        let mine = LiveCatalogRepository.discoverQuery(media: .movie, mode: .mine, providers: [119, 8], page: 2)
        XCTAssertEqual(mine["with_watch_providers"], "8|119")
        XCTAssertEqual(mine["with_watch_monetization_types"], "flatrate")
    }
    func testDirectRepositoryNormalizesTVAndUsesTurkishOffers() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [CatalogFixtureProtocol.self]
        let repository = LiveCatalogRepository(network: NetworkManager(session: URLSession(configuration: config), readToken: "fixture-token"))
        let page = try await repository.feed(media: .tv, mode: .popular, providers: [], page: 1)
        XCTAssertEqual(page.results.first?.kind, .tv)
        XCTAssertEqual(page.results.first?.displayTitle, "Dizi")
        XCTAssertEqual(page.results.first?.providersTr?.flatrate?.first?.id, 8)
        let detail = try await repository.detail(XCTUnwrap(page.results.first))
        XCTAssertEqual(detail.overview, "Özet")
        XCTAssertEqual(detail.providersTr?.flatrate?.first?.id, 8)
    }
}

// Transport fixtures exist only in the test target; the app always uses the live TMDB API.
final class CatalogFixtureProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        guard request.value(forHTTPHeaderField: "Authorization") == "Bearer fixture-token",
              let url = request.url, url.host == "api.themoviedb.org" else {
            client?.urlProtocol(self, didFailWithError: URLError(.userAuthenticationRequired)); return
        }
        let json: String
        switch url.path {
        case "/3/discover/tv": json = #"{"page":1,"total_pages":1,"results":[{"id":42,"name":"Dizi","first_air_date":"2025-01-01"}]}"#
        case "/3/tv/42": json = #"{"id":42,"overview":"Özet","genres":[],"credits":{"cast":[],"crew":[]}}"#
        case "/3/tv/42/watch/providers": json = #"{"results":{"TR":{"flatrate":[{"provider_id":8,"provider_name":"Netflix","logo_path":"/logo.jpg"}]},"US":{"buy":[{"provider_id":9,"provider_name":"US only"}]}}}"#
        default: client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL)); return
        }
        client?.urlProtocol(self, didReceive: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type":"application/json"])!, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(json.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}
