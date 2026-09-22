import XCTest
import SwiftData
@testable import CineSeeker

final class RecommendationTests: XCTestCase {
    @MainActor func testLikedFilmSeedsRecommendationsAndExcludesWatchedAndDisliked() async throws {
        let store = try store()
        store.save(Movie(id: 1, title: "Favorim", mediaType: .movie), status: .watched, rating: 9)
        store.save(Movie(id: 2, title: "İzlendi", mediaType: .movie), status: .watched)
        store.save(Movie(id: 3, title: "Beğenmedim", mediaType: .movie), status: .want, rating: 3)
        store.save(Movie(id: 4, title: "Devam", mediaType: .movie), status: .watching)
        let source = SuggestionSource(results: (1...5).map { Movie(id: $0, title: "Film \($0)", mediaType: .movie) })
        let model = RecommendationViewModel(source: source)
        await model.choose(library: store.titles, providers: [])
        XCTAssertEqual(model.pick?.movie.id, 5)
        XCTAssertTrue(model.pick?.reason.contains("9/10") == true)
        let seeds = await source.requestedSeeds
        XCTAssertEqual(seeds, [1,2])
        XCTAssertFalse(model.loading)
    }
    @MainActor func testProviderSelectionRequiresSubscriptionNotRental() async throws {
        let source = SuggestionSource(results: [Movie(id: 9, title: "Yeni", mediaType: .movie)], rentalOnly: true)
        let model = RecommendationViewModel(source: source)
        await model.choose(library: [], providers: [SuggestionSource.provider])
        XCTAssertNil(model.pick)
        XCTAssertNotNil(model.message)
        await model.choose(library: [], providers: [])
        XCTAssertEqual(model.pick?.movie.id, 9)
        XCTAssertTrue(model.pick?.reason.contains("Türkiye seçkisinden") == true)
    }
    @MainActor func testAnotherPickDoesNotRepeatUntilCandidatesExhausted() async {
        let model = RecommendationViewModel(source: SuggestionSource(results: [Movie(id: 10, title: "Bir"), Movie(id: 11, title: "İki")]))
        await model.choose(library: [], providers: [])
        let first = model.pick?.movie.id
        await model.choose(library: [], providers: [])
        XCTAssertNotNil(first)
        XCTAssertNotEqual(first, model.pick?.movie.id)
    }
    @MainActor func testRecommendationFailureIsRecoverable() async {
        let model = RecommendationViewModel(source: SuggestionSource(results: [], fails: true))
        await model.choose(library: [], providers: [])
        XCTAssertNil(model.pick)
        XCTAssertNotNil(model.message)
        XCTAssertFalse(model.loading)
    }
    @MainActor private func store() throws -> StorageManager {
        StorageManager(container: try ModelContainer(for: SavedTitle.self, SavedProvider.self, PendingMutation.self, LocalMetadata.self,
                                                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)))
    }
}
private actor SuggestionSource: RecommendationSource {
    static let provider = Provider(providerId: 8, providerName: "Netflix", logoPath: nil)
    let results: [Movie]
    var rentalOnly = false
    var fails = false
    var requestedSeeds: [Int] = []
    init(results: [Movie], rentalOnly: Bool = false, fails: Bool = false) {
        self.results = results; self.rentalOnly = rentalOnly; self.fails = fails
    }
    func relatedMovies(to movie: Movie) async throws -> [Movie] { requestedSeeds.append(movie.id); return results }
    func popularMovies(providers: [Int]) async throws -> [Movie] {
        if fails { throw URLError(.notConnectedToInternet) }
        return results
    }
    func recommendationAvailability(for movie: Movie) async throws -> Availability? {
        rentalOnly ? Availability(rent: [Self.provider]) : Availability(flatrate: [Self.provider])
    }
}
