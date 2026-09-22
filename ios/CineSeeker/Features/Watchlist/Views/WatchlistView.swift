import SwiftUI
struct WatchlistView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var model = WatchlistViewModel()
    @AppStorage("libraryGrid") private var grid = true
    private var filtered: [SavedTitle] { model.filtered(storage.titles) }
    var body: some View {
        NavigationStack {
            Group {
                if grid || filtered.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            libraryHeader
                            if filtered.isEmpty {
                                StatusPanel(title: storage.titles.isEmpty ? "Sinema günlüğün burada başlar" : "Eşleşen kayıt yok",
                                            message: storage.titles.isEmpty ? "Keşfettiğin bir hikâyenin yer imi simgesine dokun. İzleme listen çevrimdışıyken de yanında." : "Aramanı veya durum filtresini değiştirmeyi dene.", icon: "bookmark")
                            } else { MovieGrid(movies: filtered.compactMap(\.movie)) }
                        }.padding(20).frame(maxWidth: 1080).frame(maxWidth: .infinity)
                    }
                } else {
                    List {
                        libraryHeader.listRowSeparator(.hidden).listRowBackground(CineTheme.background)
                        ForEach(filtered, id: \.storageKey) { row in
                            if let movie = row.movie {
                                HStack(spacing: 12) {
                                    NavigationLink(value: movie) {
                                        HStack(spacing: 14) {
                                            if !typeSize.isAccessibilitySize {
                                                PosterImage(path: movie.posterPath, size: "w185").frame(width: 62, height: 93).clipShape(Rectangle())
                                            }
                                            VStack(alignment: .leading, spacing: 7) {
                                                Text(movie.displayTitle).font(.headline)
                                                Text(movie.year).font(.caption).foregroundStyle(.secondary)
                                                Label(row.status.title, systemImage: row.status.icon).font(.caption).foregroundStyle(CineTheme.accent)
                                                if let rating = row.rating { Label("\(rating) / 10", systemImage: "star.fill").font(.caption).foregroundStyle(CineTheme.accent) }
                                            }
                                        }.padding(.vertical, 5)
                                    }
                                    WatchMenu(movie: movie, compact: true)
                                }.swipeActions { Button("Sil", role: .destructive) { storage.remove(movie) } }.listRowBackground(CineTheme.background)
                            }
                        }
                    }.listStyle(.plain)
                }
            }.cineBackground().navigationTitle("Listem")
                .searchable(text: $model.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Listende ara")
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Menu { Picker("Sıralama", selection: $model.sort) { ForEach(LibrarySort.allCases) { Text($0.rawValue).tag($0) } } }
                        label: { Image(systemName: "arrow.up.arrow.down") }.accessibilityLabel("Listeyi sırala")
                        Button { grid.toggle() } label: { Image(systemName: grid ? "list.bullet" : "square.grid.2x2") }.accessibilityLabel(grid ? "Liste görünümü" : "Kart görünümü")
                    }
                }
                .discoveryDestinations()
        }
    }
    private var libraryHeader: some View {
        VStack(alignment: .leading, spacing: 18) {
            let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10)) : AnyLayout(HStackLayout(alignment: .firstTextBaseline))
            layout {
                Text("\(storage.titles.count) hikâye").font(.cineHeading)
                if !typeSize.isAccessibilitySize { Spacer() }
                Label("Cihazında kayıtlı", systemImage: "internaldrive").font(.caption).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }.accessibilityElement(children: .combine)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filter("Tümü", status: nil)
                    filter("İzlenecek", status: .want)
                    filter("İzliyorum", status: .watching)
                    filter("İzledim", status: .watched)
                }
            }
        }
    }
    private func filter(_ title: String, status: WatchStatus?) -> some View {
        let count = storage.titles.filter { status == nil || $0.status == status }.count
        return FilterChip(title: "\(title) · \(count)", selected: model.status == status) { model.status = status }
    }
}
