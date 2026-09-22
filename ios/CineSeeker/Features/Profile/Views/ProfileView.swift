import SwiftUI
struct ProfileView: View {
    @Environment(StorageManager.self) private var storage
    @State private var model = ProfileViewModel()
    @State private var confirmDelete = false
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        BrandWordmark()
                        Text("Sana ait bir sinema günlüğü").font(.cineHeading)
                        Text("Hesap açmadan keşfet. Listen, puanların ve platformların bu cihazda saklanır.").foregroundStyle(.secondary)
                    }.padding(.vertical, 8)
                }
                Section("Kişiselleştir") { NavigationLink { SubscriptionsView() } label: { Label("Platform Aboneliklerim", systemImage: "tv") } }
                Section {
                    Button { model.export(storage) } label: { Label("Verilerimi Dışa Aktar", systemImage: "square.and.arrow.up") }
                    if let exportURL = model.exportURL { ShareLink("JSON Dosyasını Paylaş", item: exportURL) }
                    Button("Arama Geçmişini Temizle") { storage.clearHistory(); model.clearExport() }
                    Button("Bu Cihazdaki Verilerimi Sil", role: .destructive) { confirmDelete = true }
                } header: { Text("Verilerin senin") } footer: {
                    Text("CineSeeker cihazlar arasında eşitleme yapmaz. Uygulamayı silmek yerel kayıtlarını kaldırabilir; bir kopyasını dışa aktarabilirsin.")
                }
                Section("Yasal & Kaynaklar") {
                    NavigationLink("Gizlilik") { PrivacyView() }
                    VStack(alignment: .leading, spacing: 12) {
                        Image("TMDBLogo").resizable().scaledToFit().frame(width: 120, height: 30).accessibilityLabel("The Movie Database")
                        Text("This product uses the TMDB API but is not endorsed or certified by TMDB.").font(.caption)
                        Link("TMDB", destination: URL(string: "https://www.themoviedb.org")!)
                        Text("Yayın uygunluğu verileri JustWatch tarafından sağlanır. CineSeeker yayın yapmaz; içeriklere yasal erişim seçeneklerini gösterir.").font(.caption)
                        Link("JustWatch Türkiye", destination: URL(string: "https://www.justwatch.com/tr")!)
                    }.padding(.vertical, 8)
                    Text("CineSeeker · \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.1.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))").font(.caption).foregroundStyle(.secondary)
                }
            }.cineBackground().navigationTitle("Ayarlar")
                .alert("CineSeeker", isPresented: Binding(get: { model.message != nil }, set: { if !$0 { model.message = nil } })) { Button("Tamam") { model.message = nil } } message: { Text(model.message ?? "") }
                .confirmationDialog("Bu cihazdaki tüm listen, puanların, platform seçimlerin ve arama geçmişin silinsin mi?", isPresented: $confirmDelete, titleVisibility: .visible) {
                    Button("Verilerimi Sil", role: .destructive) { model.reset(storage) }
                } message: { Text("Bu işlem geri alınamaz. İstersen önce verilerini dışa aktar.") }
        }
    }
}
struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Gizliliğin önemli.").font(.cineTitle)
                Text("CineSeeker V1 hesap oluşturmanı istemez. İzleme listen, puanların, platform seçimlerin ve son aramaların cihazında saklanır. CineSeeker’in bir hesap veya eşitleme sunucusuna gönderilmez.")
                Text("Film, dizi, görsel ve yayın bilgileri için uygulama doğrudan TMDB’ye bağlanır. Arama metni, seçtiğin tür ve platform filtreleri bu hizmete iletilir. TMDB bağlantı sırasında IP adresini görebilir.")
                Text("Ayarlar bölümünden yerel verilerini JSON dosyası olarak paylaşabilir veya cihazdaki tüm kişisel kayıtlarını silebilirsin. Paylaştığın dosyaların kopyalarını kendin yönetirsin. Cihaz yedeklerin iOS ve iCloud ayarlarına tabidir; CineSeeker cihazlar arasında eşitleme yapmaz.")
                Text("CineSeeker reklam takibi yapmaz ve uygulama içinden ücretli platform aboneliği satmaz.")
                Link("TMDB Gizlilik Politikası", destination: URL(string: "https://www.themoviedb.org/privacy-policy")!)
                Link("JustWatch Gizlilik Politikası", destination: URL(string: "https://www.justwatch.com/tr/gizlilik-politikasi")!)
            }.padding(24)
        }.cineBackground().navigationTitle("Gizlilik").navigationBarTitleDisplayMode(.inline)
    }
}
