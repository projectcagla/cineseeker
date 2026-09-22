import Foundation
import Observation
@MainActor @Observable final class MovieDetailViewModel {
    var detail: MovieDetail?
    var loading = false
    var error: String?
    private var generation = UUID()
    private let repository: any CatalogRepository
    init(repository: any CatalogRepository = LiveCatalogRepository()) { self.repository = repository }
    func load(_ movie: Movie) async {
        let token = UUID(); generation = token
        loading = true; error = nil
        defer { if token == generation { loading = false } }
        do {
            let response = try await repository.detail(movie)
            try Task.checkCancellation()
            guard generation == token else { return }
            detail = response
        } catch { if !Task.isCancelled && generation == token { self.error = error.localizedDescription } }
    }
    func availability(for movie: Movie) -> Availability? {
        guard let detail, detail.providersError != true else { return movie.providersTr }
        // A successful response without TR offers must replace older saved availability.
        return detail.providersTr
    }
    var trailer: CatalogVideo? {
        detail?.videos?.results.filter { $0.url != nil }.sorted {
            func priority(_ video: CatalogVideo) -> Int {
                (video.official == true ? 4 : 0) + (video.iso6391 == "tr" ? 2 : 0) + (video.type == "Trailer" ? 1 : 0)
            }
            return priority($0) > priority($1)
        }.first
    }
    func related(to movie: Movie) -> [Movie] {
        var seen = Set([movie.key])
        return (detail?.recommendations?.results ?? []).compactMap {
            var item = $0; item.mediaType = movie.kind
            return seen.insert(item.key).inserted ? item : nil
        }
    }
}
