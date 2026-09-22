import Foundation
import Observation

@MainActor @Observable final class PersonViewModel {
    var profile: PersonProfile?
    var biography: String?
    var biographyIsEnglish = false
    var entries: [FilmographyEntry] = []
    var media: MediaType?
    var role: FilmographyRole = .all
    var sort: FilmographySort = .popular
    var query = ""
    var loading = false
    var error: String?
    private let repository: any PersonRepository
    private var generation = UUID()
    init(repository: any PersonRepository = LiveCatalogRepository(), role: FilmographyRole = .all) {
        self.repository = repository; self.role = role
    }
    var availableRoles: [FilmographyRole] {
        [.all] + FilmographyRole.allCases.filter { role in role != .all && entries.contains { $0.roles.contains(role) } }
    }
    var filtered: [FilmographyEntry] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).searchKey
        return entries.filter {
            (media == nil || $0.movie.kind == media) && (role == .all || $0.roles.contains(role)) &&
            (needle.isEmpty || $0.movie.displayTitle.searchKey.contains(needle) || $0.movie.original.searchKey.contains(needle))
        }.sorted { left, right in
            let leftDate = left.movie.releaseDate ?? left.movie.firstAirDate ?? ""
            let rightDate = right.movie.releaseDate ?? right.movie.firstAirDate ?? ""
            switch sort {
            case .popular:
                if left.popularity != right.popularity { return left.popularity > right.popularity }
            case .newest, .oldest:
                // Undated titles stay at the end in both chronological directions.
                if leftDate.isEmpty != rightDate.isEmpty { return !leftDate.isEmpty }
                if leftDate != rightDate { return sort == .newest ? leftDate > rightDate : leftDate < rightDate }
            }
            return left.id < right.id
        }
    }
    func load(id: Int) async {
        let token = UUID(); generation = token
        loading = true; error = nil
        defer { if generation == token { loading = false } }
        do {
            let result = try await repository.person(id: id, language: "tr-TR", includingCredits: true)
            try Task.checkCancellation()
            guard generation == token else { return }
            profile = result
            entries = result.combinedCredits.map(FilmographyEntry.merged) ?? []
            if !availableRoles.contains(role) { role = .all }
            biography = result.biography?.nonEmpty; biographyIsEnglish = false
            if biography == nil {
                // Keep the Turkish filmography usable even when the optional biography fails.
                let fallback = try? await repository.person(id: id, language: "en-US", includingCredits: false)
                try Task.checkCancellation()
                guard generation == token else { return }
                biography = fallback?.biography?.nonEmpty
                biographyIsEnglish = biography != nil
            }
        } catch { if !Task.isCancelled && generation == token { self.error = error.localizedDescription } }
    }
}
