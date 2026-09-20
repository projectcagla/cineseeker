import Foundation
struct LiveCatalogRepository: CatalogRepository {
    let network: NetworkManager
    init(network: NetworkManager = .shared) { self.network = network }
    static func discoverQuery(media: MediaType, mode: FeedMode, providers: [Int], page: Int, now: Date = Date()) -> [String: String] {
        var params = ["page": String(page), "region": "TR", "watch_region": "TR", "include_adult": "false",
                      "with_watch_monetization_types": "flatrate|rent|buy", "sort_by": "popularity.desc"]
        if mode == .mine { params["with_watch_providers"] = providers.sorted().map(String.init).joined(separator: "|"); params["with_watch_monetization_types"] = "flatrate" }
        if mode == .arrivals {
            let formatter = DateFormatter(); formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0); formatter.dateFormat = "yyyy-MM-dd"
            let dateField = media == .movie ? "primary_release_date" : "first_air_date"
            params["sort_by"] = "\(dateField).desc"
            params["\(dateField).gte"] = formatter.string(from: now.addingTimeInterval(-180 * 86400))
            params["\(dateField).lte"] = formatter.string(from: now)
        }
        return params
    }
    func feed(media: MediaType, mode: FeedMode, providers: [Int], page: Int) async throws -> MoviePage {
        guard mode != .mine || !providers.isEmpty else { return MoviePage(results: [], page: 1, totalPages: 1) }
        let result: MoviePage = try await network.request(.init(path: "discover/\(media.rawValue)", query: Self.discoverQuery(media: media, mode: mode, providers: providers, page: page)))
        return try await enrich(result, media: media)
    }
    func search(_ query: String, media: MediaType, genre: Int?, page: Int) async throws -> MoviePage {
        var params = Self.discoverQuery(media: media, mode: .popular, providers: [], page: page)
        let path: String
        if query.isEmpty {
            path = "discover/\(media.rawValue)"
            if let genre { params["with_genres"] = String(genre) }
        } else {
            path = "search/\(media.rawValue)"
            params = ["query": query, "page": String(page), "include_adult": "false", "region": "TR"]
        }
        var result: MoviePage = try await network.request(.init(path: path, query: params))
        // TMDB text search has no genre parameter. Filter each returned page, preserving pagination.
        if !query.isEmpty, let genre { result = MoviePage(results: result.results.filter { $0.genreIds?.contains(genre) == true }, page: result.page, totalPages: result.totalPages) }
        return try await enrich(result, media: media)
    }
    private struct Offers: Decodable, Sendable { let results: [String: Availability] }
    private func offers(_ movie: Movie) async throws -> Availability? {
        let response: Offers = try await network.request(.init(path: "\(movie.kind.rawValue)/\(movie.id)/watch/providers"))
        return response.results["TR"]
    }
    private func enrich(_ page: MoviePage, media: MediaType) async throws -> MoviePage {
        var movies = page.results.map { movie in var copy = movie; copy.mediaType = media; return copy }
        // Keep provider lookups bounded to five concurrent requests and retain source ordering.
        for start in stride(from: 0, to: movies.count, by: 5) {
            try Task.checkCancellation()
            let chunk = Array(movies[start..<min(start + 5, movies.count)])
            let enriched = try await withThrowingTaskGroup(of: (Int, Movie).self) { group in
                for (offset, movie) in chunk.enumerated() {
                    group.addTask {
                        var enriched = movie
                        do { enriched.providersTr = try await offers(movie) }
                        catch { try Task.checkCancellation(); enriched.providersError = true }
                        return (offset, enriched)
                    }
                }
                var values: [(Int, Movie)] = []
                for try await value in group { values.append(value) }
                return values.sorted { $0.0 < $1.0 }.map(\.1)
            }
            movies.replaceSubrange(start..<start + chunk.count, with: enriched)
        }
        return MoviePage(results: movies, page: page.page, totalPages: min(500, page.totalPages))
    }
    func detail(_ movie: Movie) async throws -> MovieDetail {
        async let details: MovieDetail = network.request(.init(path: "\(movie.kind.rawValue)/\(movie.id)", query: ["append_to_response": "credits"]))
        async let availability = offers(movie)
        var result = try await details; result.providersTr = try await availability
        return result
    }
    func providers() async throws -> [Provider] {
        async let movies: ProviderPage = network.request(.init(path: "watch/providers/movie", query: ["watch_region": "TR"]))
        async let television: ProviderPage = network.request(.init(path: "watch/providers/tv", query: ["watch_region": "TR"]))
        let combined = try await movies.results + television.results
        var seen = Set<Int>()
        return combined.filter { seen.insert($0.id).inserted }.sorted { $0.providerName < $1.providerName }
    }
    func genres(_ media: MediaType) async throws -> [Genre] {
        let page: GenrePage = try await network.request(.init(path: "genre/\(media.rawValue)/list")); return page.genres
    }
}
