import SwiftUI
struct SubscriptionsView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var loading = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Senin platformların.\nSana göre keşif.").font(.cineTitle)
                Text("Abone olduğun servisleri seç. Sana ait olanları yeşil rozetle öne çıkaralım.").foregroundStyle(.secondary)
                if loading { ProgressView("Platformlar yükleniyor…") }
                if storage.allProviders.isEmpty && !loading {
                    StatusPanel(title: "Platform kataloğu bekleniyor", message: "Güncel Türkiye platformları sunucu bağlantısı kurulduğunda yüklenir.", icon: "tv") { Task { await refresh() } }
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 14)], spacing: 14) {
                    ForEach(storage.allProviders) { provider in
                        let selected = storage.isSubscribed(provider)
                        Button {
                            withAnimation(reduceMotion ? nil : .snappy(duration: 0.25)) { storage.toggle(provider) }
                        } label: {
                            VStack(spacing: 12) {
                                PosterImage(path: provider.logoPath, size: "w185").frame(width: 56, height: 56).clipShape(RoundedRectangle(cornerRadius: 14))
                                Text(provider.providerName).font(.headline).multilineTextAlignment(.center)
                                Label(selected ? "Abonesiniz" : "Seç", systemImage: selected ? "checkmark.circle.fill" : "plus.circle").font(.caption).foregroundStyle(selected ? .green : .secondary)
                            }.padding(20).frame(maxWidth: .infinity, minHeight: 155)
                                .background(selected ? Color.green.opacity(0.08) : CineTheme.surface, in: RoundedRectangle(cornerRadius: 20))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(selected ? .green : .white.opacity(0.08)))
                        }.buttonStyle(.plain).accessibilityLabel("\(provider.providerName), \(selected ? "abonesiniz, kaldır" : "abonelik ekle")")
                    }
                }
                Text("Seçim yapmak ücretli abonelik başlatmaz. Platform adları Türkiye kataloğundaki güncel adlarıyla gösterilir.").font(.caption).foregroundStyle(.secondary)
            }.padding(20)
        }.cineBackground().navigationTitle("Platformlarım").navigationBarTitleDisplayMode(.inline)
            .task { if storage.allProviders.isEmpty { await refresh() } }.refreshable { await refresh() }
    }
    private func refresh() async { loading = true; await storage.refreshProviders(); loading = false }
}
