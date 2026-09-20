import Foundation
import SwiftData
import Observation
@MainActor @Observable final class StorageManager {
    let context: ModelContext
    var owner = "guest"
    var titles: [SavedTitle] = []
    var selected: [Provider] = []
    var allProviders: [Provider] = []
    var recentSearches: [String] = []
    var error: String?
    init(container: ModelContainer) {
        context = ModelContext(container)
        context.autosaveEnabled = false
        do {
            allProviders = try metadata("providerCatalog", as: [Provider].self) ?? []
            recentSearches = try metadata("search:guest", as: [String].self) ?? []
            try reload()
        } catch { self.error = error.localizedDescription }
    }
    func metadata<T: Decodable>(_ key: String, as: T.Type) throws -> T? {
        let rows = try context.fetch(FetchDescriptor<LocalMetadata>())
        guard let row = rows.first(where: { $0.key == key }) else { return nil }
        return try JSONDecoder().decode(Optional<T>.self, from: row.data)
    }
    func storeMetadata<T: Encodable>(_ value: T, key: String) throws {
        let data = try JSONEncoder().encode(value)
        let rows = try context.fetch(FetchDescriptor<LocalMetadata>())
        if let row = rows.first(where: { $0.key == key }) { row.data = data }
        else { context.insert(LocalMetadata(key: key, data: data)) }
        try context.save()
    }
    func switchOwner(_ id: String) throws {
        owner = id
        recentSearches = try metadata("search:\(id)", as: [String].self) ?? []
        try reload()
    }
    func reload() throws {
        titles = try context.fetch(FetchDescriptor<SavedTitle>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])).filter { $0.owner == owner }
        selected = try context.fetch(FetchDescriptor<SavedProvider>()).filter { $0.owner == owner }.compactMap(\.provider)
    }
    func item(_ movie: Movie) -> SavedTitle? { titles.first { $0.movie?.key == movie.key } }
    func isSubscribed(_ provider: Provider) -> Bool { selected.contains { $0.id == provider.id } }
    func save(_ movie: Movie, status: WatchStatus, rating: Int? = nil) {
        do {
            guard rating == nil || (1...10).contains(rating!) else { return }
            if let row = item(movie) { row.statusValue = status.rawValue; row.rating = rating; row.updatedAt = Date() }
            else { context.insert(try SavedTitle(owner: owner, movie: movie, status: status, rating: rating)) }
            try context.save(); try reload(); HapticManager.selection()
        } catch { context.rollback(); self.error = error.localizedDescription; try? reload() }
    }
    func remove(_ movie: Movie) {
        do {
            if let row = item(movie) { context.delete(row) }
            try context.save(); try reload()
        } catch { context.rollback(); self.error = error.localizedDescription; try? reload() }
    }
    func toggle(_ provider: Provider) {
        do {
            let rows = try context.fetch(FetchDescriptor<SavedProvider>())
            let row = rows.first { $0.owner == owner && $0.provider?.id == provider.id }
            if let row { context.delete(row) } else { context.insert(try SavedProvider(owner: owner, provider: provider)) }
            try context.save(); try reload(); HapticManager.selection()
        } catch { context.rollback(); self.error = error.localizedDescription; try? reload() }
    }
    func remember(_ query: String) {
        let clean = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        recentSearches = Array(([clean] + recentSearches.filter { $0 != clean }).prefix(10))
        do { try storeMetadata(recentSearches, key: "search:\(owner)") } catch { self.error = error.localizedDescription }
    }
    func clearHistory() {
        recentSearches = []
        do { try storeMetadata(recentSearches, key: "search:\(owner)") } catch { self.error = error.localizedDescription }
    }
    func refreshProviders() async {
        do { allProviders = try await LiveCatalogRepository().providers(); try storeMetadata(allProviders, key: "providerCatalog") }
        catch { self.error = error.localizedDescription }
    }
    func resetLocalData() throws {
        for row in try context.fetch(FetchDescriptor<SavedTitle>()) { context.delete(row) }
        for row in try context.fetch(FetchDescriptor<SavedProvider>()) { context.delete(row) }
        for row in try context.fetch(FetchDescriptor<PendingMutation>()) { context.delete(row) }
        for row in try context.fetch(FetchDescriptor<LocalMetadata>()) where row.key != "providerCatalog" { context.delete(row) }
        try context.save(); owner = "guest"; recentSearches = []; try reload()
    }
    func localExport() throws -> Data {
        let items = titles.compactMap { row -> RemoteItem? in
            guard let movie = row.movie else { return nil }
            return RemoteItem(tmdbId: movie.id, mediaType: movie.kind, title: movie.displayTitle, posterPath: movie.posterPath,
                              voteAverage: movie.voteAverage.map(String.init(describing:)), releaseYear: movie.year, status: row.status, rating: row.rating)
        }
        struct Export: Encodable { let exportedAt: Date; let watchlist: [RemoteItem]; let providers: [Provider]; let searches: [String] }
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]; encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(Export(exportedAt: Date(), watchlist: items, providers: selected, searches: recentSearches))
    }
}
