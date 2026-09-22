import SwiftUI

struct RecommendationView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.dismiss) private var dismiss
    @State private var model = RecommendationViewModel()
    @State private var usePlatforms = true
    @State private var request = UUID()
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("SEÇİMİ BİZE BIRAK.").font(.cineTitle)
                    Text("Sevdiğin hikâyelerden yeni bir filme.").foregroundStyle(.secondary)
                    if !storage.selected.isEmpty {
                        Toggle("Platformlarımda olsun", isOn: $usePlatforms).font(.subheadline)
                        Text("Açıksa yalnızca seçtiğin platformlardaki abonelik seçenekleri kullanılır.").font(.caption).foregroundStyle(.secondary)
                    }
                    if model.loading {
                        ProgressView("Sana bir film seçiliyor…").frame(maxWidth: .infinity).padding(.vertical, 48)
                    } else if let pick = model.pick {
                        VStack(alignment: .leading, spacing: 18) {
                            PosterImage(path: pick.movie.backdropPath ?? pick.movie.posterPath, size: "w780").frame(height: 220)
                            Text(pick.movie.displayTitle).font(.cineTitle)
                            Text([pick.movie.year.nonEmpty, "FİLM"].compactMap { $0 }.joined(separator: " / ")).font(.cineLabel).foregroundStyle(.secondary)
                            Text(pick.reason).font(.body).fixedSize(horizontal: false, vertical: true)
                            Rectangle().fill(CineTheme.border).frame(height: 1)
                            Text(pick.movie.overview?.nonEmpty ?? "Ayrıntılarda yayın seçeneklerini inceleyebilirsin.").font(.subheadline).foregroundStyle(.secondary).lineLimit(5)
                            NavigationLink(value: pick.movie) {
                                Label("FİLMİ İNCELE", systemImage: "arrow.up.right").frame(maxWidth: .infinity)
                            }.buttonStyle(CineButtonStyle())
                        }
                    }
                    if let message = model.message {
                        Text(message).foregroundStyle(.secondary).padding(.vertical, 16)
                    }
                    Button { request = UUID(); HapticManager.selection() } label: {
                        Label(model.pick == nil ? "YENİDEN DENE" : "BAŞKA BİR FİLM", systemImage: "shuffle").frame(maxWidth: .infinity)
                    }.buttonStyle(CineButtonStyle(prominent: false)).disabled(model.loading)
                    Text("Öneri, TMDB’nin bu filmlerle ilişkilendirdiği öneriler arasından rastgele seçilir. İzlediklerin, izlemekte oldukların ve 7’nin altında puanladıkların elenir.")
                        .font(.caption).foregroundStyle(.secondary)
                }.padding(20).frame(maxWidth: 760).frame(maxWidth: .infinity)
            }.cineBackground().navigationTitle("SANA BİR FİLM").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Bitti") { dismiss() } } }
                .task(id: "\(request):\(usePlatforms)") { await model.choose(library: storage.titles, providers: usePlatforms ? storage.selected : []) }
                .discoveryDestinations()
        }
    }
}
