import SwiftUI
import SwiftData
@main struct CineSeekerApp: App {
    private let container: ModelContainer?
    private let startupError: String?
    @State private var storage: StorageManager?
    @State private var account = AccountViewModel()
    init() {
        do {
            let container = try ModelContainer(for: SavedTitle.self, SavedProvider.self, PendingMutation.self, LocalMetadata.self)
            self.container = container; startupError = nil
            _storage = State(initialValue: StorageManager(container: container))
        } catch { container = nil; startupError = error.localizedDescription; _storage = State(initialValue: nil) }
    }
    var body: some Scene {
        WindowGroup {
            if let storage {
                RootView().environment(storage).environment(account).preferredColorScheme(.dark).tint(CineTheme.accent)
            } else {
                StatusPanel(title: "Kayıtlar açılamadı", message: "Verilerin korunuyor. Uygulamayı yeniden başlatmayı dene. \(startupError ?? "")", icon: "externaldrive.badge.exclamationmark").preferredColorScheme(.dark)
            }
        }
    }
}
struct RootView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(AccountViewModel.self) private var account
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        TabView {
            DiscoverView().tabItem { Label("Keşfet", systemImage: "sparkles.tv") }
            SearchView().tabItem { Label("Ara", systemImage: "magnifyingglass") }
            WatchlistView().tabItem { Label("Listem", systemImage: "bookmark") }
            ProfileView().tabItem { Label("Hesabım", systemImage: "person.crop.circle") }
        }
        .task { await account.restore(storage) }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            // Retry the persisted outbox while foregrounded, including after connectivity returns.
            while !Task.isCancelled {
                await storage.sync()
                do { try await Task.sleep(for: .seconds(30)) } catch { break }
            }
        }
        .alert("İşlem tamamlanamadı", isPresented: Binding(get: { storage.error != nil }, set: { if !$0 { storage.error = nil } })) { Button("Tamam") { storage.error = nil } } message: { Text(storage.error ?? "") }
    }
}
