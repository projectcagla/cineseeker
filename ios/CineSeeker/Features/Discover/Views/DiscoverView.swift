import SwiftUI
struct DiscoverView: View {
    @Environment(StorageManager.self) private var storage
    @State private var model = DiscoverViewModel()
    @State private var showPlatforms = false
    private var taskID: String { "\(model.media.rawValue):\(model.mode.rawValue):\(storage.selected.map(\.id).sorted())" }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("BU AKŞAMIN HİKÂYESİ").font(.caption.weight(.semibold)).tracking(3).foregroundStyle(CineTheme.accent)
                        Text("İyi bir hikâye bul.").font(.cineTitle)
                        Text("Türkiye’de nerede izleyeceğini keşfet.").foregroundStyle(.secondary)
                    }.padding(.top, 10)
                    Picker("İçerik türü", selection: $model.media) { ForEach(MediaType.allCases) { Text($0.title).tag($0) } }.pickerStyle(.segmented)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(FeedMode.allCases) { mode in
                                Button { model.mode = mode } label: {
                                    Text(mode.rawValue).font(.subheadline.weight(.semibold)).padding(.horizontal, 16).padding(.vertical, 12)
                                        .background(model.mode == mode ? CineTheme.accent : CineTheme.surface, in: Capsule())
                                        .foregroundStyle(model.mode == mode ? .black : .white)
                                }.accessibilityAddTraits(model.mode == mode ? .isSelected : [])
                            }
                        }
                    }
                    if model.mode == .mine && storage.selected.isEmpty {
                        StatusPanel(title: "Platformlarını seç", message: "Abone olduğun servislerdeki hikâyeleri bir araya getirelim.", icon: "rectangle.stack.badge.plus")
                        Button("Platformlarımı Seç") { showPlatforms = true }.buttonStyle(.borderedProminent).frame(maxWidth: .infinity)
                    } else {
                        if !model.movies.isEmpty && model.mode == .popular {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 14) {
                                    ForEach(Array(model.movies.prefix(5)), id: \.key) { movie in
                                        NavigationLink(value: movie) {
                                            ZStack(alignment: .bottomLeading) {
                                                PosterImage(path: movie.backdropPath ?? movie.posterPath, size: "w780")
                                                LinearGradient(colors: [.clear, .black.opacity(0.95)], startPoint: .top, endPoint: .bottom)
                                                VStack(alignment: .leading, spacing: 8) {
                                                    Text("ÖNE ÇIKAN").font(.caption.bold()).tracking(2).foregroundStyle(CineTheme.accent)
                                                    Text(movie.displayTitle).font(.cineHeading).foregroundStyle(.white)
                                                    Label("\(movie.year) · Keşfet", systemImage: "play.circle.fill").font(.subheadline).foregroundStyle(.white.opacity(0.8))
                                                }.padding(22)
                                            }.frame(height: 300).clipShape(RoundedRectangle(cornerRadius: 24))
                                        }.containerRelativeFrame(.horizontal, count: 1, spacing: 14)
                                    }
                                }.scrollTargetLayout()
                            }.scrollTargetBehavior(.viewAligned)
                        }
                        if model.mode == .arrivals { Text("Son 30 günde taramalarda ilk kez görülen yayınlar. İlk tarama başlangıç kataloğudur; kesin prömiyer tarihi değildir.").font(.caption).foregroundStyle(.secondary) }
                        if let error = model.error { StatusPanel(title: "Bağlantı kurulamadı", message: error, icon: "wifi.exclamationmark") { Task { await reload() } } }
                        MovieGrid(movies: model.movies)
                        if model.loading { ProgressView("Hikâyeler yükleniyor…").frame(maxWidth: .infinity).padding() }
                        else if model.movies.isEmpty && model.error == nil { StatusPanel(title: "Henüz içerik yok", message: model.mode == .arrivals ? "Yeni platform kayıtları sunucu taramalarıyla burada belirecek." : "Filtreleri değiştirerek yeniden deneyebilirsin.") }
                        if model.page < model.totalPages && !model.movies.isEmpty { Button("Daha Fazla Göster") { Task { await model.load(providers: storage.selected.map(\.id), more: true) } }.buttonStyle(.bordered).frame(maxWidth: .infinity) }
                    }
                    Text("Yayın verileri: JustWatch · Film ve dizi bilgileri: TMDB").font(.caption2).foregroundStyle(.secondary).frame(maxWidth: .infinity).padding(.vertical)
                }.padding(.horizontal, 20)
            }.cineBackground().navigationTitle("CineSeeker").navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Movie.self) { MovieDetailView(movie: $0) }
                .task(id: taskID) { await reload() }.refreshable { await reload() }
                .sheet(isPresented: $showPlatforms) { NavigationStack { SubscriptionsView().toolbar { Button("Bitti") { showPlatforms = false } } } }
        }
    }
    private func reload() async { await model.load(providers: storage.selected.map(\.id)) }
}
