import Foundation
import Observation
@MainActor @Observable final class MovieDetailViewModel {
    var detail: MovieDetail?
    var loading = false
    var error: String?
    func load(_ movie: Movie) async {
        loading = true; error = nil; defer { loading = false }
        do { detail = try await LiveCatalogRepository().detail(movie) }
        catch is CancellationError {} catch { self.error = error.localizedDescription }
    }
}
