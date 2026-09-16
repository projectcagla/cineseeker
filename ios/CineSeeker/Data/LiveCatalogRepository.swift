import Foundation
struct LiveCatalogRepository: CatalogRepository {
    let network = NetworkManager.shared
    func feed(media: MediaType, mode: FeedMode, providers: [Int], page: Int) async throws -> MoviePage {
        var params = ["page": String(page)]
        if mode == .mine { params["providers"] = providers.map(String.init).joined(separator: "|") }
        return try await network.request(.catalog(mode == .arrivals ? "arrivals" : "discover", media: media, params: params))
    }
    func search(_ query: String, media: MediaType, genre: Int?, page: Int) async throws -> MoviePage {
        var params = ["page": String(page)]
        if !query.isEmpty { params["query"] = query }
        if let genre { params["genre"] = String(genre) }
        return try await network.request(.catalog(query.isEmpty ? "discover" : "search", media: media, params: params))
    }
    func detail(_ movie: Movie) async throws -> MovieDetail { try await network.request(.catalog("detail", media: movie.kind, params: ["id": String(movie.id)])) }
    func providers() async throws -> [Provider] {
        let page: ProviderPage = try await network.request(.catalog("providers")); return page.results.sorted { $0.providerName < $1.providerName }
    }
    func genres(_ media: MediaType) async throws -> [Genre] {
        let page: GenrePage = try await network.request(.catalog("genres", media: media)); return page.genres
    }
}
