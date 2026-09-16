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
    @MainActor func testAccountOutboxPersistsAndDeletionKeepsGuestData() throws {
        let container = try ModelContainer(for: SavedTitle.self, SavedProvider.self, PendingMutation.self, LocalMetadata.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let store = StorageManager(container: container)
        let movie = Movie(id: 19, title: "Kayıt", mediaType: .movie)
        store.save(movie, status: .want)
        try store.switchOwner("account-a")
        store.save(movie, status: .watched, rating: 8)
        let operations = try store.context.fetch(FetchDescriptor<PendingMutation>())
        XCTAssertEqual(operations.count, 1)
        XCTAssertEqual(operations.first?.owner, "account-a")
        let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: XCTUnwrap(operations.first?.body)) as? [String: Any])
        XCTAssertEqual(payload["kind"] as? String, "save")
        try store.storeMetadata(Optional<User>.none, key: "lastUser")
        XCTAssertNil(try store.metadata("lastUser", as: User.self))
        try store.eraseAccount("account-a")
        XCTAssertTrue(try store.context.fetch(FetchDescriptor<PendingMutation>()).isEmpty)
        XCTAssertEqual(store.item(movie)?.status, .want)
    }

}
