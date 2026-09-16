import Foundation
import Observation
@MainActor @Observable final class SearchViewModel {
    var query = ""
    var media: MediaType = .movie
    var genre: Int?
    var genres: [Genre] = []
    var movies: [Movie] = []
    var loading = false
    var error: String?
    var page = 0
    var totalPages = 1
    private var generation = UUID()
    private let repository: any CatalogRepository
    init(repository: any CatalogRepository = LiveCatalogRepository()) { self.repository = repository }
    func loadGenres() async {
        do { genres = try await repository.genres(media) } catch { self.error = error.localizedDescription }
    }
    func search(more: Bool = false) async {
        if more && (loading || page >= totalPages) { return }
        let token = UUID(); generation = token; loading = true; error = nil
        if !more { movies = []; page = 0 }
        defer { if token == generation { loading = false } }
        do {
            if !more { try await Task.sleep(for: .milliseconds(300)) }
            let result = try await repository.search(query.trimmingCharacters(in: .whitespacesAndNewlines), media: media, genre: genre, page: page + 1)
            try Task.checkCancellation(); guard token == generation else { return }
            var seen = Set(movies.map(\.key))
            movies += result.results.filter { seen.insert($0.key).inserted }
            page = result.page; totalPages = result.totalPages
        } catch is CancellationError {} catch { if token == generation { self.error = error.localizedDescription } }
    }
}
