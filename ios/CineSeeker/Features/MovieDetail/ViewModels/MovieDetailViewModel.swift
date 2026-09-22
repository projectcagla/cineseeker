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
}
