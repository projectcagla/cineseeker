import SwiftUI
struct DiscoverView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var model = DiscoverViewModel()
    @State private var showPlatforms = false
    private var taskID: String { "\(model.media.rawValue):\(model.mode.rawValue):\(storage.selected.map(\.id).sorted())" }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BU AKŞAM NE İZLESEK?").font(.caption.weight(.semibold)).tracking(2.5).foregroundStyle(CineTheme.accent)
                        Text("İyi bir hikâye bul.").font(.cineTitle)
                        Text("Aradığın hikâye. İzleyeceğin yer.").font(.subheadline).foregroundStyle(.secondary)
                    }.padding(.top, 12)
                    Picker("İçerik türü", selection: $model.media) { ForEach(MediaType.allCases) { Text($0.title).tag($0) } }.pickerStyle(.segmented)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(FeedMode.allCases) { mode in
                                FilterChip(title: mode.rawValue, selected: model.mode == mode) { model.mode = mode; HapticManager.selection() }
                            }
                        }
                    }.contentMargins(.vertical, 2)
                    if model.mode == .mine && storage.selected.isEmpty {
                        StatusPanel(title: "Keşfi kendine göre ayarla", message: "Abone olduğun platformları seç; sana açık olan hikâyeleri bir araya getirelim.", icon: "tv")
                        Button("Platformlarımı Seç") { showPlatforms = true }.buttonStyle(.borderedProminent).controlSize(.large).frame(maxWidth: .infinity)
                    } else {
                        if !model.movies.isEmpty && model.mode == .popular { hero }
                        SectionHeading(title: sectionTitle, subtitle: sectionSubtitle)
                        if let error = model.error { StatusPanel(title: "Kataloğa ulaşılamadı", message: error, icon: "wifi.exclamationmark") { Task { await reload() } } }
                        if model.loading && model.movies.isEmpty { LoadingCards() }
                        else { MovieGrid(movies: model.movies) }
                        if model.loading && !model.movies.isEmpty { ProgressView("Yükleniyor…").frame(maxWidth: .infinity).padding() }
                        if !model.loading && model.movies.isEmpty && model.error == nil {
                            StatusPanel(title: "Bu seçimde içerik yok", message: "Başka bir içerik türü veya platform seçerek yeniden deneyebilirsin.")
                        }
                        if !model.loading && model.page < model.totalPages && !model.movies.isEmpty {
                            Button("Daha Fazla Keşfet") { Task { await model.load(providers: storage.selected.map(\.id), more: true) } }
                                .buttonStyle(.bordered).controlSize(.large).frame(maxWidth: .infinity)
                        }
                    }
                    Text("Türkiye kataloğu · Yayın verileri JustWatch\nFilm ve dizi bilgileri TMDB")
                        .font(.caption2).multilineTextAlignment(.center).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                }.padding(.horizontal, 20).frame(maxWidth: 1080).frame(maxWidth: .infinity)
            }.cineBackground().navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) { BrandWordmark() }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showPlatforms = true } label: { Image(systemName: "slider.horizontal.3") }
                            .accessibilityLabel("Platform aboneliklerini düzenle")
                    }
                }
                .navigationDestination(for: Movie.self) { MovieDetailView(movie: $0) }
                .task(id: taskID) { await reload() }.refreshable { await reload() }
                .sheet(isPresented: $showPlatforms) { NavigationStack { SubscriptionsView().toolbar { Button("Bitti") { showPlatforms = false } } } }
        }
    }
    private var sectionTitle: String {
        switch model.mode { case .popular: "İzlemeye değer"; case .mine: "Aboneliklerinde keşfet"; case .arrivals: "Yeni hikâyeler" }
    }
    private var sectionSubtitle: String {
        switch model.mode {
        case .popular: "Türkiye’de yayın seçeneği bulunan popüler içerikler."
        case .mine: "Seçtiğin \(storage.selected.count) platformdaki içerikler."
        case .arrivals: "Son 6 ayda çıkan içerikler; platforma eklenme tarihi değildir."
        }
    }
    private var hero: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 14) {
                ForEach(Array(model.movies.prefix(5)), id: \.key) { movie in
                    NavigationLink(value: movie) {
                        ZStack(alignment: .bottomLeading) {
                            PosterImage(path: movie.backdropPath ?? movie.posterPath, size: "w780")
                            LinearGradient(colors: [.black.opacity(0.05), .black.opacity(0.9)], startPoint: .center, endPoint: .bottom)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("GÜNÜN SEÇKİSİ").font(.caption2.bold()).tracking(2).foregroundStyle(CineTheme.accent)
                                Text(movie.displayTitle).font(.cineHeading).lineLimit(typeSize.isAccessibilitySize ? 4 : 2)
                                HStack(spacing: 6) {
                                    Text(movie.year)
                                    Text("·")
                                    Text("Nerede izlenir?")
                                    Image(systemName: "arrow.up.right")
                                }.font(.subheadline).foregroundStyle(.white.opacity(0.85))
                            }.padding(24)
                        }.frame(height: typeSize.isAccessibilitySize ? 420 : 320).foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 26))
                            .overlay(RoundedRectangle(cornerRadius: 26).strokeBorder(CineTheme.border))
                    }.buttonStyle(.plain).containerRelativeFrame(.horizontal, count: 1, spacing: 14)
                        .accessibilityLabel("Öne çıkan: \(movie.displayTitle), ayrıntıları aç")
                }
            }.scrollTargetLayout()
        }.scrollTargetBehavior(.viewAligned)
    }
    private func reload() async { await model.load(providers: storage.selected.map(\.id)) }
}
