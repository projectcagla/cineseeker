import SwiftUI
import UniformTypeIdentifiers
struct ProfileView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(AccountViewModel.self) private var account
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var registering = false
    @State private var confirmDelete = false
    @State private var exportURL: URL?
    @State private var exporting = false
    var body: some View {
        NavigationStack {
            Form {
                if AppConfiguration.baseURL == nil {
                    Section("Sunucu kurulumu") { Text("CineSeeker sunucusu henüz yapılandırılmadı. Yerel izleme listeniz çalışır; keşif ve hesap için Config.xcconfig dosyasında HTTPS sunucu adresini ayarlayın.").font(.subheadline).foregroundStyle(.secondary) }
                }
                if let user = account.user {
                    Section("Hesabın") {
                        Label(user.email, systemImage: "envelope")
                        TextField("Görünen ad", text: $name).textContentType(.name)
                        Button("Profili Güncelle") { Task { await account.updateName(name, storage: storage) } }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || account.busy)
                        TextField("Yeni e-posta adresi", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled()
                        Button("Yeni E-postayı Doğrula") { Task { await account.changeEmail(email) } }.disabled(email.isEmpty || account.busy)
                        Button("Şifre Sıfırlama E-postası Gönder") { Task { await account.resetPassword(email: user.email) } }
                        Button("Çıkış Yap") { Task { await account.signOut(storage) } }
                    }.onAppear { name = user.name }
                } else {
                    Section(registering ? "Hesap oluştur" : "Kaldığın yerden devam et") {
                        if registering { TextField("Adın", text: $name).textContentType(.name) }
                        TextField("E-posta", text: $email).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled().textContentType(.emailAddress)
                        SecureField("Şifre", text: $password).textContentType(registering ? .newPassword : .password)
                        Button(registering ? "Kayıt Ol" : "Giriş Yap") {
                            Task { await account.authenticate(email: email.trimmingCharacters(in: .whitespaces), password: password, name: name, registering: registering, storage: storage); password = "" }
                        }.disabled(account.busy || email.isEmpty || password.count < 8 || (registering && name.isEmpty))
                        Button(registering ? "Zaten hesabım var" : "Yeni hesap oluştur") { registering.toggle() }
                        Button("Şifremi Unuttum") { Task { await account.resetPassword(email: email) } }.disabled(email.isEmpty || account.busy)
                    }
                    Section { Text("Misafir listesi bu cihazda saklanır. Giriş yaptığında hesap listen ayrı olarak açılır.").font(.caption).foregroundStyle(.secondary) }
                }
                Section("Kişiselleştir") { NavigationLink { SubscriptionsView() } label: { Label("Platform Aboneliklerim", systemImage: "tv") } }
                Section("Verilerin senin") {
                    Button { exporting = true; Task { do { exportURL = try await account.export(storage) } catch { account.message = error.localizedDescription }; exporting = false } } label: { Label("Tüm Verilerimi İndir", systemImage: "square.and.arrow.up") }.disabled(exporting || account.busy)
                    if let exportURL { ShareLink("JSON Dosyasını Paylaş", item: exportURL) }
                    Button("Arama Geçmişini Temizle") { storage.clearHistory() }
                    if account.user != nil { Button("Hesabımı Kalıcı Olarak Sil", role: .destructive) { confirmDelete = true }.disabled(account.busy) }
                }
                Section("Yasal & Kaynaklar") {
                    NavigationLink("Gizlilik ve KVKK") { PrivacyView() }
                    VStack(alignment: .leading, spacing: 12) {
                        Image("TMDBLogo").resizable().scaledToFit().frame(width: 120, height: 30).accessibilityLabel("The Movie Database")
                        Text("This product uses the TMDB API but is not endorsed or certified by TMDB.").font(.caption)
                        Link("TMDB", destination: URL(string: "https://www.themoviedb.org")!)
                        Text("Yayın uygunluğu verileri JustWatch tarafından sağlanır. CineSeeker yayın yapmaz; içeriklere yasal erişim seçeneklerini gösterir.").font(.caption)
                        Link("JustWatch Türkiye", destination: URL(string: "https://www.justwatch.com/tr")!)
                    }.padding(.vertical, 8)
                    Text("CineSeeker · 1.0.0").font(.caption).foregroundStyle(.secondary)
                }
            }.cineBackground().navigationTitle("Hesabım")
                .onChange(of: account.user?.id) { _, _ in
                    if let exportURL { try? FileManager.default.removeItem(at: exportURL) }
                    exportURL = nil
                }
                .overlay { if account.busy || exporting { ProgressView().padding(24).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16)) } }
                .alert("CineSeeker", isPresented: Binding(get: { account.message != nil }, set: { if !$0 { account.message = nil } })) { Button("Tamam") { account.message = nil } } message: { Text(account.message ?? "") }
                .confirmationDialog("Hesabın ve sunucudaki tüm verilerin kalıcı olarak silinsin mi?", isPresented: $confirmDelete, titleVisibility: .visible) {
                    Button("Hesabımı ve Verilerimi Sil", role: .destructive) { Task { await account.deleteAccount(storage) } }
                } message: { Text("Bu işlem geri alınamaz. İstersen önce verilerini dışa aktar.") }
        }
    }
}
struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Gizliliğin önemli.").font(.cineTitle)
                Text("İzleme listen, puanların ve platform seçimlerin cihazında saklanır. Giriş yaptığında bu kayıtlar CineSeeker hesabınla eşitlenir. Son aramaların yalnızca cihazında tutulur.")
                Text("Hesap işlemleri için e-posta ve görünen ad kullanılır. Oturum bilgileri iOS Keychain’de saklanır. Film görselleri TMDB’den alınır; bu bağlantılarda IP adresin ilgili sunucu tarafından görülebilir.")
                Text("Hesap bölümünden cihaz ve hesap verilerini JSON olarak indirebilir veya hesabını kalıcı olarak silebilirsin. CineSeeker reklam takibi yapmaz ve uygulama içinden ücretli platform aboneliği satmaz.")
                if let base = AppConfiguration.baseURL {
                    Link("Veri sorumlusu, saklama süreleri ve başvuru bilgileri", destination: base.appendingPathComponent("gizlilik"))
                    Link("Kullanım koşulları", destination: base.appendingPathComponent("yasal"))
                } else { Text("Veri sorumlusu ve iletişim bilgileri sunucu yayınlanırken gizlilik sayfasında tanımlanmalıdır.").foregroundStyle(.secondary) }
            }.padding(24)
        }.cineBackground().navigationTitle("Gizlilik ve KVKK").navigationBarTitleDisplayMode(.inline)
    }
}
