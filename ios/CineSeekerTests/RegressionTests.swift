import XCTest
import SwiftData
@testable import CineSeeker

final class RegressionTests: XCTestCase {
    func testTurkishSearchSupportsUnaccentedInput() {
        XCTAssertEqual("İSTANBUL".searchKey, "istanbul")
        XCTAssertEqual("IŞIK".searchKey, "isik")
        XCTAssertEqual("ışık".searchKey, "isik")
        XCTAssertEqual("  Çağrı  ".searchKey, "cagri")
    }
    @MainActor func testResetRemovesExportFromPreviousViewModel() throws {
        let store = try makeStore()
        store.save(Movie(id: 9, title: "Kayıt"), status: .want)
        let first = ProfileViewModel()
        first.export(store)
        let url = try XCTUnwrap(first.exportURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        let reopened = ProfileViewModel()
        reopened.reset(store)
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        XCTAssertTrue(store.titles.isEmpty)
    }
    @MainActor func testUpdatingSavedTitleRefreshesOfflineMetadata() throws {
        let store = try makeStore()
        store.save(Movie(id: 8, title: "Eski", mediaType: .movie), status: .want)
        store.save(Movie(id: 8, title: "Yeni", posterPath: "/new.jpg", mediaType: .movie), status: .watched, rating: 9)
        XCTAssertEqual(store.titles.count, 1)
        XCTAssertEqual(store.titles.first?.movie?.displayTitle, "Yeni")
        XCTAssertEqual(store.titles.first?.movie?.posterPath, "/new.jpg")
    }
    @MainActor func testLibrarySearchCombinesStatusAndRatingSort() throws {
        let store = try makeStore()
        store.save(Movie(id: 1, title: "İstanbul", mediaType: .movie), status: .watched, rating: 7)
        store.save(Movie(id: 2, title: "İstanbul Hatırası", mediaType: .movie), status: .watched, rating: 9)
        store.save(Movie(id: 3, title: "İstanbul", mediaType: .tv), status: .want)
        let model = WatchlistViewModel(); model.query = "istanbul"; model.status = .watched; model.sort = .rating
        XCTAssertEqual(model.filtered(store.titles).compactMap { $0.movie?.id }, [2, 1])
    }
    @MainActor func testSuccessfulEmptyOffersReplaceStaleSavedOffers() async {
        let provider = Provider(providerId: 8, providerName: "Netflix", logoPath: nil)
        let movie = Movie(id: 42, title: "Film", providersTr: Availability(flatrate: [provider]))
        let model = MovieDetailViewModel(repository: ScenarioCatalog())
        XCTAssertNotNil(model.availability(for: movie))
        await model.load(movie)
        XCTAssertNotNil(model.detail)
        XCTAssertNil(model.availability(for: movie))
    }
    func testOfferFailureKeepsMovieSynopsisAndCredits() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [PartialDetailProtocol.self]
        let repository = LiveCatalogRepository(network: NetworkManager(session: URLSession(configuration: config), readToken: "fixture"))
        let detail = try await repository.detail(Movie(id: 42, title: "Film", mediaType: .movie))
        XCTAssertEqual(detail.overview, "Türkçe özet")
        XCTAssertEqual(detail.runtime, 120)
        XCTAssertEqual(detail.providersError, true)
    }
    @MainActor func testRefreshFailurePreservesExistingFeed() async {
        let model = DiscoverViewModel(repository: ScenarioCatalog())
        await model.load(providers: [])
        XCTAssertEqual(model.movies.count, 1)
        await model.load(providers: [])
        XCTAssertEqual(model.movies.count, 1)
        XCTAssertEqual(model.page, 1)
        XCTAssertNotNil(model.error)
        XCTAssertFalse(model.loading)
    }
    @MainActor func testCancelledGenreRequestCannotReplaceNewMediaGenres() async {
        let repository = GenreGateCatalog()
        let model = SearchViewModel(repository: repository)
        let first = Task { await model.loadGenres() }
        await repository.waitUntilMovieRequested()
        model.media = .tv
        await model.loadGenres()
        first.cancel()
        await repository.finishMovieRequest()
        await first.value
        XCTAssertEqual(model.genres.map(\.name), ["TV türü"])
        XCTAssertNil(model.error)
    }
    @MainActor func testSavedLibrarySurvivesNewDiskContainer() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("Library.store")
        func container() throws -> ModelContainer {
            try ModelContainer(for: SavedTitle.self, SavedProvider.self, PendingMutation.self, LocalMetadata.self,
                               configurations: ModelConfiguration(url: url))
        }
        do {
            let store = StorageManager(container: try container())
            store.save(Movie(id: 90, title: "Kalıcı", mediaType: .movie), status: .watched, rating: 8)
            store.toggle(Provider(providerId: 8, providerName: "Netflix", logoPath: nil))
        }
        let reopened = StorageManager(container: try container())
        XCTAssertEqual(reopened.titles.first?.rating, 8)
        XCTAssertEqual(reopened.selected.first?.id, 8)
    }
    @MainActor private func makeStore() throws -> StorageManager {
        StorageManager(container: try ModelContainer(for: SavedTitle.self, SavedProvider.self, PendingMutation.self, LocalMetadata.self,
                                                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
    }
}
private actor ScenarioCatalog: CatalogRepository {
    private var calls = 0
    func feed(media: MediaType, mode: FeedMode, providers: [Int], page: Int) async throws -> MoviePage {
        calls += 1
        if calls > 1 { throw URLError(.notConnectedToInternet) }
        return MoviePage(results: [Movie(id: 1, title: "Film")], page: 1, totalPages: 2)
    }
    func detail(_ movie: Movie) async throws -> MovieDetail { MovieDetail(id: movie.id, overview: "Özet", runtime: 100, episodeRunTime: nil, numberOfSeasons: nil, genres: [], credits: nil) }
    func search(_ query: String, media: MediaType, genre: Int?, page: Int) async throws -> MoviePage { MoviePage(results: [], page: 1, totalPages: 1) }
    func providers() async throws -> [Provider] { [] }
    func genres(_ media: MediaType) async throws -> [Genre] { [] }
}
private actor GenreGateCatalog: CatalogRepository {
    private var movieContinuation: CheckedContinuation<[Genre], Never>?
    private var observer: CheckedContinuation<Void, Never>?
    func waitUntilMovieRequested() async {
        if movieContinuation != nil { return }
        await withCheckedContinuation { observer = $0 }
    }
    func finishMovieRequest() { movieContinuation?.resume(returning: [Genre(id: 1, name: "Eski film türü")]); movieContinuation = nil }
    func genres(_ media: MediaType) async throws -> [Genre] {
        if media == .tv { return [Genre(id: 2, name: "TV türü")] }
        return await withCheckedContinuation { continuation in
            movieContinuation = continuation; observer?.resume(); observer = nil
        }
    }
    func feed(media: MediaType, mode: FeedMode, providers: [Int], page: Int) async throws -> MoviePage { MoviePage(results: [], page: 1, totalPages: 1) }
    func search(_ query: String, media: MediaType, genre: Int?, page: Int) async throws -> MoviePage { MoviePage(results: [], page: 1, totalPages: 1) }
    func providers() async throws -> [Provider] { [] }
    func detail(_ movie: Movie) async throws -> MovieDetail { throw URLError(.unsupportedURL) }
}
private final class PartialDetailProtocol: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        guard let url = request.url else { return }
        let failed = url.path.hasSuffix("providers")
        client?.urlProtocol(self, didReceive: HTTPURLResponse(url: url, statusCode: failed ? 503 : 200, httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data((failed ? "{}" : #"{"id":42,"overview":"Türkçe özet","runtime":120,"genres":[],"credits":{"cast":[],"crew":[]}}"#).utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}
