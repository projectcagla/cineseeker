import Foundation

protocol RecommendationSource: Sendable {
    func relatedMovies(to movie: Movie) async throws -> [Movie]
    func popularMovies(providers: [Int]) async throws -> [Movie]
    func recommendationAvailability(for movie: Movie) async throws -> Availability?
}

struct RecommendationPick: Sendable {
    let movie: Movie
    let reason: String
}
