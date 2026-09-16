import Foundation
import Observation
@MainActor @Observable final class DiscoverViewModel {
    var media: MediaType = .movie
    var mode: FeedMode = .popular
    var movies: [Movie] = []
    var loading = false
    var error: String?
    var page = 0
    var totalPages = 1
    private var generation = UUID()
    private let repository: any CatalogRepository
    init(repository: any CatalogRepository = LiveCatalogRepository()) { self.repository = repository }
    func load(providers: [Int], more: Bool = false) async {
        if more && (loading || page >= totalPages) { return }
        let token = UUID(); generation = token
        loading = true; error = nil
        if !more { movies = []; page = 0 }
        if mode == .mine && providers.isEmpty { loading = false; return }
        defer { if generation == token { loading = false } }
        do {
            let response = try await repository.feed(media: media, mode: mode, providers: providers, page: page + 1)
            try Task.checkCancellation(); guard generation == token else { return }
            var seen = Set(movies.map(\.key))
            movies += response.results.filter { seen.insert($0.key).inserted }; page = response.page; totalPages = response.totalPages
        } catch is CancellationError {} catch { if generation == token { self.error = error.localizedDescription } }
    }
}
