import SwiftUI
struct SearchView: View {
    @Environment(StorageManager.self) private var storage
    @State private var model = SearchViewModel()
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionHeading(title: "Aklındaki hikâyeyi bul.", subtitle: "Türkçe veya orijinal adıyla ara, türlere göz at.")
                    Picker("İçerik türü", selection: $model.media) { ForEach(MediaType.allCases) { Text($0.title).tag($0) } }.pickerStyle(.segmented)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "Tüm türler", selected: model.genre == nil) { model.genre = nil }
                            ForEach(model.genres) { genre in FilterChip(title: genre.name, selected: model.genre == genre.id) { model.genre = genre.id } }
                        }
                    }
                    if model.query.isEmpty && !storage.recentSearches.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Son aramalar").font(.headline)
                                Spacer()
                                Button("Temizle") { storage.clearHistory() }.font(.subheadline).frame(minHeight: 44)
                            }
                            ForEach(storage.recentSearches.prefix(5), id: \.self) { query in
                                Button { model.query = query } label: {
                                    HStack {
                                        Image(systemName: "clock.arrow.circlepath").foregroundStyle(.secondary)
                                        Text(query).foregroundStyle(.primary)
                                        Spacer()
                                        Image(systemName: "arrow.up.left").foregroundStyle(.secondary)
                                    }.font(.subheadline).frame(minHeight: 44)
                                }.buttonStyle(.plain)
                            }
                        }.padding(16).background(CineTheme.surface, in: RoundedRectangle(cornerRadius: 20))
                    }
                    if let error = model.error { StatusPanel(title: "Arama yapılamadı", message: error, icon: "wifi.exclamationmark") { Task { await model.search() } } }
                    if model.loading && model.movies.isEmpty { LoadingCards() }
                    else { MovieGrid(movies: model.movies) }
                    if model.loading && !model.movies.isEmpty { ProgressView("Aranıyor…").frame(maxWidth: .infinity) }
                    if !model.loading && model.movies.isEmpty && model.error == nil {
                        StatusPanel(title: "Sonuç bulunamadı", message: model.page < model.totalPages ? "Bu sayfada seçtiğin türe uygun içerik yok. Sonraki sonuçlara göz atabilirsin." : "Başka bir isim veya tür deneyebilirsin.", icon: "magnifyingglass")
                    }
                    if model.page < model.totalPages && !model.loading {
                        Button("Daha Fazla Sonuç") { Task { await model.search(more: true) } }.buttonStyle(.bordered).controlSize(.large).frame(maxWidth: .infinity)
                    }
                }.padding(20).frame(maxWidth: 1080).frame(maxWidth: .infinity)
            }.cineBackground().navigationTitle("Ara")
                .scrollDismissesKeyboard(.interactively)
                .searchable(text: $model.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Film, dizi veya orijinal adı")
                .onSubmit(of: .search) { storage.remember(model.query) }
                .task(id: "\(model.query)|\(model.media.rawValue)|\(model.genre ?? 0)") { await model.search() }
                .task(id: model.media) { model.genre = nil; await model.loadGenres() }
                .navigationDestination(for: Movie.self) { movie in MovieDetailView(movie: movie).onAppear { storage.remember(model.query) } }
        }
    }
}
