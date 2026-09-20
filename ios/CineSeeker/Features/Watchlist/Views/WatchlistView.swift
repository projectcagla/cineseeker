import SwiftUI
struct WatchlistView: View {
    @Environment(StorageManager.self) private var storage
    @State private var model = WatchlistViewModel()
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        filter("Tümü", status: nil)
                        filter("İzlenecekler", status: .want)
                        filter("İzliyorum", status: .watching)
                        filter("İzlediklerim", status: .watched)
                    }.padding(.horizontal, 20)
                }
                if model.filtered(storage.titles).isEmpty {
                    StatusPanel(title: "Bir sonraki hikâyen burada", message: "Keşfettiğin filmleri ve dizileri kaydet; internet olmadan da listene ulaş.", icon: "bookmark")
                    Spacer()
                } else if model.grid {
                    ScrollView { MovieGrid(movies: model.filtered(storage.titles).compactMap(\.movie)).padding(20) }
                } else {
                    List {
                        ForEach(model.filtered(storage.titles), id: \.storageKey) { row in
                            if let movie = row.movie {
                                HStack(spacing: 12) {
                                    NavigationLink(value: movie) {
                                        HStack(spacing: 12) {
                                            PosterImage(path: movie.posterPath, size: "w185").frame(width: 54, height: 81).clipShape(RoundedRectangle(cornerRadius: 8))
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(movie.displayTitle).font(.headline)
                                                Text(row.status.title).font(.caption).foregroundStyle(.secondary)
                                                if let rating = row.rating { Label("\(rating) / 10", systemImage: "star.fill").font(.caption).foregroundStyle(CineTheme.accent) }
                                            }
                                        }
                                    }
                                    WatchMenu(movie: movie, compact: true)
                                }.swipeActions { Button("Sil", role: .destructive) { storage.remove(movie) } }.listRowBackground(CineTheme.surface)
                            }
                        }
                    }.listStyle(.plain).cineBackground()
                }
            }.padding(.top, 12).cineBackground().navigationTitle("İzleme Listem")
                .toolbar { Button { model.grid.toggle() } label: { Image(systemName: model.grid ? "list.bullet" : "square.grid.2x2") }.accessibilityLabel(model.grid ? "Liste görünümü" : "Kart görünümü") }
                .navigationDestination(for: Movie.self) { MovieDetailView(movie: $0) }
        }
    }
    private func filter(_ title: String, status: WatchStatus?) -> some View {
        Button { model.status = status } label: {
            Text(title).font(.subheadline).padding(10).background(model.status == status ? CineTheme.accent : CineTheme.surface, in: Capsule()).foregroundStyle(model.status == status ? .black : .white)
        }.accessibilityAddTraits(model.status == status ? .isSelected : [])
    }
}
