import Foundation
import Observation

@MainActor @Observable final class RecommendationViewModel {
    var pick: RecommendationPick?
    var loading = false
    var message: String?
    private var shown = Set<String>()
    private var generation = UUID()
    private let source: any RecommendationSource
    init(source: any RecommendationSource = LiveCatalogRepository()) { self.source = source }

    func choose(library: [SavedTitle], providers: [Provider]) async {
        let token = UUID(); generation = token
        loading = true; message = nil
        defer { if generation == token { loading = false } }
        // Ratings below seven are not positive signals, even when the film was watched.
        let seeds = library.filter {
            $0.movie?.kind == .movie && (($0.rating ?? 0) >= 7 || ($0.status == .watched && $0.rating == nil))
        }.sorted {
            let left = $0.rating ?? 6, right = $1.rating ?? 6
            return left == right ? $0.updatedAt > $1.updatedAt : left > right
        }.prefix(3)
        let excluded = Set(library.filter {
            $0.status == .watched || $0.status == .watching || ($0.rating != nil && ($0.rating ?? 10) < 7)
        }.compactMap { $0.movie?.key })
        var pool: [String: RecommendationPick] = [:]
        var failedRequests = 0
        do {
            for seed in seeds {
                guard let movie = seed.movie else { continue }
                do {
                    let results = try await source.relatedMovies(to: movie)
                    try Task.checkCancellation()
                    for result in results where !excluded.contains(result.key) && result.kind == .movie {
                        if pool[result.key] == nil {
                            let reason = seed.rating.map { "\(movie.displayTitle) filmine verdiğin \($0)/10 puana göre." }
                                ?? "\(movie.displayTitle) filmini izlediğin için."
                            pool[result.key] = RecommendationPick(movie: result, reason: reason)
                        }
                    }
                } catch { try Task.checkCancellation(); failedRequests += 1 }
            }
            if pool.isEmpty {
                let results = try await source.popularMovies(providers: providers.map(\.id))
                let reason = seeds.isEmpty
                    ? "Türkiye seçkisinden. İzlediğin filmleri kaydedip puan verdikçe öneriler kişiselleşir."
                    : "Geçmişinden yeni bir eşleşme bulunamadı. Türkiye seçkisinden bir alternatif."
                for result in results where !excluded.contains(result.key) && result.kind == .movie {
                    pool[result.key] = RecommendationPick(movie: result, reason: reason)
                }
            }
            try Task.checkCancellation()
            guard generation == token else { return }
            var candidates = pool.values.filter { !shown.contains($0.movie.key) }
            if candidates.isEmpty && !pool.isEmpty {
                // Cycle only after the pool is exhausted; avoid immediately repeating the last pick.
                shown = []
                candidates = pool.values.filter { pool.count == 1 || $0.movie.key != pick?.movie.key }
            }
            // Verify regional offers only for sampled candidates, with at most 12 sequential requests.
            for candidate in candidates.shuffled().prefix(12) {
                do {
                    let availability = try await source.recommendationAvailability(for: candidate.movie)
                    try Task.checkCancellation()
                    guard generation == token else { return }
                    guard let availability, !availability.all.isEmpty else { continue }
                    if !providers.isEmpty {
                        let allowed = Set(providers.map(\.id))
                        guard availability.flatrate?.contains(where: { allowed.contains($0.id) }) == true else { continue }
                    }
                    var movie = candidate.movie; movie.providersTr = availability; movie.providersError = false
                    shown.insert(movie.key)
                    pick = RecommendationPick(movie: movie, reason: candidate.reason)
                    return
                } catch { try Task.checkCancellation(); failedRequests += 1 }
            }
            pick = nil
            message = failedRequests > 0
                ? "Öneri verilerinin bir kısmına ulaşılamadı. Yeniden deneyebilirsin."
                : providers.isEmpty ? "İzlemediğin ve Türkiye’de yayın seçeneği olan yeni bir film bulunamadı. Başka bir seçim için yeniden dene."
                : "Bu turda seçili aboneliklerinde yeni bir eşleşme bulunamadı. Yeniden deneyebilir veya platform filtresini kapatabilirsin."
        } catch {
            guard !Task.isCancelled, generation == token else { return }
            message = error.localizedDescription
        }
    }
}
