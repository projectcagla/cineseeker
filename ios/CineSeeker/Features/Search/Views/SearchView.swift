import SwiftUI
struct SearchView: View {
    @Environment(StorageManager.self) private var storage
    @State private var model = SearchViewModel()
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Picker("İçerik türü", selection: $model.media) { ForEach(MediaType.allCases) { Text($0.title).tag($0) } }.pickerStyle(.segmented)
                    Picker("Tür", selection: $model.genre) {
                        Text("Tüm Türler").tag(Int?.none)
                        ForEach(model.genres) { Text($0.name).tag(Optional($0.id)) }
                    }.pickerStyle(.menu)
                    if model.query.isEmpty && !storage.recentSearches.isEmpty {
                        HStack { Text("Son aramalar").font(.headline); Spacer(); Button("Temizle") { storage.clearHistory() }.font(.caption) }
                        ForEach(storage.recentSearches, id: \.self) { query in
                            Button { model.query = query } label: { Label(query, systemImage: "clock.arrow.circlepath").foregroundStyle(.secondary) }.frame(minHeight: 44)
                        }
                    }
                    if model.loading { ProgressView("Aranıyor…").frame(maxWidth: .infinity) }
                    if let error = model.error { StatusPanel(title: "Arama yapılamadı", message: error) { Task { await model.search() } } }
                    MovieGrid(movies: model.movies)
                    if !model.loading && model.movies.isEmpty && model.error == nil { StatusPanel(title: "Sonuç bulunamadı", message: "Başka bir isim veya tür deneyebilirsin.", icon: "magnifyingglass") }
                    if model.page < model.totalPages && !model.loading { Button("Daha Fazla Sonuç") { Task { await model.search(more: true) } }.buttonStyle(.bordered).frame(maxWidth: .infinity) }
                }.padding(20)
            }.cineBackground().navigationTitle("Ara & Keşfet")
                .searchable(text: $model.query, prompt: "Film, dizi veya orijinal adı")
                .onSubmit(of: .search) { storage.remember(model.query) }
                .task(id: "\(model.query)|\(model.media.rawValue)|\(model.genre ?? 0)") { await model.search() }
                .task(id: model.media) { model.genre = nil; await model.loadGenres() }
                .navigationDestination(for: Movie.self) { movie in MovieDetailView(movie: movie).onAppear { storage.remember(model.query) } }
        }
    }
}
