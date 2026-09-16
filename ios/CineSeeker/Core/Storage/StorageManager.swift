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
    var syncMessage: String?
    private var syncing = false
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
    private func enqueue(_ body: [String: Any]) throws {
        if owner != "guest" { context.insert(PendingMutation(owner: owner, body: try JSONSerialization.data(withJSONObject: body))) }
    }
    func save(_ movie: Movie, status: WatchStatus, rating: Int? = nil) {
        do {
            guard rating == nil || (1...10).contains(rating!) else { return }
            if let row = item(movie) { row.statusValue = status.rawValue; row.rating = rating; row.updatedAt = Date() }
            else { context.insert(try SavedTitle(owner: owner, movie: movie, status: status, rating: rating)) }
            let remote = RemoteItem(tmdbId: movie.id, mediaType: movie.kind, title: movie.displayTitle, posterPath: movie.posterPath,
                                    voteAverage: movie.voteAverage.map(String.init(describing:)), releaseYear: movie.year, status: status, rating: rating)
            var payload = try JSONSerialization.jsonObject(with: JSONEncoder().encode(remote)) as! [String: Any]
            payload["rating"] = rating.map { $0 as Any } ?? NSNull()
            try enqueue(["kind": "save", "item": payload])
            try context.save(); try reload(); HapticManager.selection()
            Task { await sync() }
        } catch { context.rollback(); self.error = error.localizedDescription; try? reload() }
    }
    func remove(_ movie: Movie) {
        do {
            if let row = item(movie) { context.delete(row) }
            try enqueue(["kind": "remove", "tmdbId": movie.id, "mediaType": movie.kind.rawValue])
            try context.save(); try reload(); Task { await sync() }
        } catch { context.rollback(); self.error = error.localizedDescription; try? reload() }
    }
    func toggle(_ provider: Provider) {
        do {
            let rows = try context.fetch(FetchDescriptor<SavedProvider>())
            let row = rows.first { $0.owner == owner && $0.provider?.id == provider.id }
            if let row { context.delete(row) } else { context.insert(try SavedProvider(owner: owner, provider: provider)) }
            try enqueue(["kind": "provider", "selected": row == nil, "provider": ["providerId": provider.id, "providerName": provider.providerName, "logoPath": provider.logoPath ?? ""]])
            try context.save(); try reload(); HapticManager.selection(); Task { await sync() }
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
    func sync() async {
        guard owner != "guest", !syncing else { return }
        syncing = true
        let account = owner
        defer { syncing = false }
        do {
            // Drain persisted operations in order; re-read after each await to include edits made during sync.
            while owner == account {
                let pending = try context.fetch(FetchDescriptor<PendingMutation>(sortBy: [SortDescriptor(\.createdAt)])).filter { $0.owner == account }
                guard let operation = pending.first else { break }
                _ = try await NetworkManager.shared.data(.init(path: "api/mobile/library", method: "POST", body: operation.body, expectedUser: account))
                guard owner == account else { return }
                context.delete(operation); try context.save()
            }
            let library: RemoteLibrary = try await NetworkManager.shared.request(.init(path: "api/mobile/library", expectedUser: account))
            guard owner == account else { return }
            // Never overwrite local edits that arrived while the GET was in flight.
            let pending = try context.fetch(FetchDescriptor<PendingMutation>()).contains { $0.owner == account }
            if pending { syncing = false; await sync(); return }
            for row in try context.fetch(FetchDescriptor<SavedTitle>()) where row.owner == account { context.delete(row) }
            for row in try context.fetch(FetchDescriptor<SavedProvider>()) where row.owner == account { context.delete(row) }
            for item in library.watchlist { context.insert(try SavedTitle(owner: account, movie: item.movie, status: item.status, rating: item.rating)) }
            for provider in library.providers { context.insert(try SavedProvider(owner: account, provider: provider.provider)) }
            try context.save(); try reload(); syncMessage = nil
        } catch { context.rollback(); syncMessage = "Değişiklikler cihazınızda. Eşitleme yeniden denenecek: \(error.localizedDescription)" }
    }
    func eraseAccount(_ id: String) throws {
        for row in try context.fetch(FetchDescriptor<SavedTitle>()) where row.owner == id { context.delete(row) }
        for row in try context.fetch(FetchDescriptor<SavedProvider>()) where row.owner == id { context.delete(row) }
        for row in try context.fetch(FetchDescriptor<PendingMutation>()) where row.owner == id { context.delete(row) }
        for row in try context.fetch(FetchDescriptor<LocalMetadata>()) where row.key == "search:\(id)" || row.key == "lastUser" { context.delete(row) }
        try context.save(); try switchOwner("guest")
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
