import SwiftUI
struct SubscriptionsView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var loading = false
    @State private var query = ""
    @State private var selectedOnly = false
    @Environment(\.dynamicTypeSize) private var typeSize
    private var providers: [Provider] {
        storage.allProviders.filter { provider in
            (!selectedOnly || storage.isSubscribed(provider)) && (query.isEmpty || provider.providerName.searchKey.contains(query.searchKey))
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Senin platformların.\nSana göre keşif.").font(.cineTitle)
                Text("Abone olduğun servisleri seç. Sana ait olanları yeşil rozetle öne çıkaralım.").foregroundStyle(.secondary)
                let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12)) : AnyLayout(HStackLayout())
                layout {
                    Text("\(storage.selected.count) platform seçili").font(.subheadline.weight(.semibold))
                    if !typeSize.isAccessibilitySize { Spacer() }
                    Toggle("Seçtiklerim", isOn: $selectedOnly).font(.caption)
                }
                if providers.isEmpty && !storage.allProviders.isEmpty {
                    StatusPanel(title: "Platform bulunamadı", message: "Aramanı veya seçili platform filtresini değiştirebilirsin.", icon: "tv")
                }
                if loading { ProgressView("Platformlar yükleniyor…") }
                if storage.allProviders.isEmpty && !loading {
                    StatusPanel(title: "Platform kataloğu bekleniyor", message: "Güncel Türkiye platformları katalog bağlantısı kurulduğunda yüklenir.", icon: "tv") { Task { await refresh() } }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: typeSize.isAccessibilitySize ? 280 : 150), spacing: 14)], spacing: 14) {
                    ForEach(providers) { provider in
                        let selected = storage.isSubscribed(provider)
                        Button {
                            withAnimation(reduceMotion ? nil : .snappy(duration: 0.25)) { storage.toggle(provider) }
                        } label: {
                            VStack(spacing: 12) {
                                PosterImage(path: provider.logoPath, size: "w185").frame(width: 56, height: 56).clipShape(Rectangle())
                                Text(provider.providerName).font(.headline).multilineTextAlignment(.center)
                                Label(selected ? "Abonesiniz" : "Seç", systemImage: selected ? "checkmark.circle.fill" : "plus.circle").font(.caption).foregroundStyle(selected ? CineTheme.success : .secondary)
                            }.padding(20).frame(maxWidth: .infinity, minHeight: 155)
                                .background(selected ? Color.green.opacity(0.08) : CineTheme.surface, in: Rectangle())
                                .overlay(Rectangle().stroke(selected ? CineTheme.success : CineTheme.border))
                        }.buttonStyle(.plain).accessibilityLabel("\(provider.providerName), \(selected ? "abonesiniz, kaldır" : "abonelik ekle")")
                    }
                }
                Text("Seçim yapmak ücretli abonelik başlatmaz. Platform adları Türkiye kataloğundaki güncel adlarıyla gösterilir.").font(.caption).foregroundStyle(.secondary)
            }.padding(20).frame(maxWidth: 1080).frame(maxWidth: .infinity)
        }.cineBackground().navigationTitle("Platformlarım").navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Platform ara")
            .task { if storage.allProviders.isEmpty { await refresh() } }.refreshable { await refresh() }
    }
    private func refresh() async { loading = true; await storage.refreshProviders(); loading = false }
}
