import Foundation

extension LiveCatalogRepository: RecommendationSource {
    func relatedMovies(to movie: Movie) async throws -> [Movie] {
        let page: MoviePage = try await network.request(.init(path: "movie/\(movie.id)/recommendations", query: ["page": "1"]))
        return page.results.map { var item = $0; item.mediaType = .movie; return item }
    }
    func popularMovies(providers: [Int]) async throws -> [Movie] {
        let page: MoviePage = try await network.request(.init(path: "discover/movie", query: Self.discoverQuery(media: .movie, mode: providers.isEmpty ? .popular : .mine, providers: providers, page: 1)))
        return page.results.map { var item = $0; item.mediaType = .movie; return item }
    }
    func recommendationAvailability(for movie: Movie) async throws -> Availability? {
        struct Response: Decodable, Sendable { let results: [String: Availability] }
        let response: Response = try await network.request(.init(path: "movie/\(movie.id)/watch/providers"))
        return response.results["TR"]
    }
}
