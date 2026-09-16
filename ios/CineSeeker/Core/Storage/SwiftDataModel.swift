import Foundation
import SwiftData
@Model final class SavedTitle {
    @Attribute(.unique) var storageKey: String
    var owner: String
    var movieData: Data
    var statusValue: String
    var rating: Int?
    var updatedAt: Date
    init(owner: String, movie: Movie, status: WatchStatus, rating: Int?) throws {
        storageKey = "\(owner):\(movie.key)"; self.owner = owner
        movieData = try JSONEncoder().encode(movie); statusValue = status.rawValue
        self.rating = rating; updatedAt = Date()
    }
    var movie: Movie? { try? JSONDecoder().decode(Movie.self, from: movieData) }
    var status: WatchStatus { WatchStatus(rawValue: statusValue) ?? .want }
}
@Model final class SavedProvider {
    @Attribute(.unique) var storageKey: String
    var owner: String
    var providerData: Data
    init(owner: String, provider: Provider) throws {
        storageKey = "\(owner):\(provider.id)"; self.owner = owner
        providerData = try JSONEncoder().encode(provider)
    }
    var provider: Provider? { try? JSONDecoder().decode(Provider.self, from: providerData) }
}
@Model final class PendingMutation {
    @Attribute(.unique) var id: UUID
    var owner: String
    var body: Data
    var createdAt: Date
    init(owner: String, body: Data) { id = UUID(); self.owner = owner; self.body = body; createdAt = Date() }
}
@Model final class LocalMetadata {
    @Attribute(.unique) var key: String
    var data: Data
    init(key: String, data: Data) { self.key = key; self.data = data }
}
