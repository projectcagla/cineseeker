import SwiftUI
struct MovieDetailView: View {
    let movie: Movie
    @Environment(StorageManager.self) private var storage
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var model = MovieDetailViewModel()
    private var availability: Availability? { model.availability(for: movie) }
    private var sharingURL: URL { URL(string: "https://www.themoviedb.org/\(movie.kind.rawValue)/\(movie.id)")! }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                header
                VStack(alignment: .leading, spacing: 28) {
                    metadata
                    WatchMenu(movie: movie)
                    if let item = storage.item(movie) { rating(item) }
                    if model.loading { ProgressView("Ayrıntılar yükleniyor…") }
                    if let error = model.error { StatusPanel(title: "Ayrıntılar yenilenemedi", message: error, icon: "wifi.exclamationmark") { Task { await model.load(movie) } } }
                    streaming
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeading(title: "Hikâye")
                        Text(model.detail?.overview?.nonEmpty ?? movie.overview?.nonEmpty ?? "Türkçe özet henüz bulunmuyor.")
                            .foregroundStyle(.secondary).lineSpacing(5).textSelection(.enabled)
                    }
                    if let credits = model.detail?.credits { cast(credits) }
                    Text("Film ve dizi bilgileri TMDB tarafından sağlanır.").font(.caption2).foregroundStyle(.secondary)
                }.padding(.horizontal, 20).padding(.bottom, 32)
            }.frame(maxWidth: 900).frame(maxWidth: .infinity)
        }.cineBackground().navigationBarTitleDisplayMode(.inline)
            .toolbar { ShareLink(item: sharingURL, subject: Text(movie.displayTitle), message: Text("CineSeeker’de keşfettim: \(movie.displayTitle)")) { Image(systemName: "square.and.arrow.up") }.accessibilityLabel("İçeriği paylaş") }
            .task(id: movie.key) { await model.load(movie) }
            .refreshable { await model.load(movie) }
    }
    private var header: some View {
        VStack(alignment: .leading, spacing: -48) {
            PosterImage(path: movie.backdropPath ?? movie.posterPath, size: "w780")
                .frame(height: 240)
                .overlay(LinearGradient(colors: [.clear, CineTheme.background], startPoint: .center, endPoint: .bottom))
            HStack(alignment: .bottom, spacing: 18) {
                if !typeSize.isAccessibilitySize {
                    PosterImage(path: movie.posterPath, size: "w185").frame(width: 100, height: 150)
                        .clipShape(Rectangle())
                        .overlay(Rectangle().strokeBorder(CineTheme.border))

                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.kind == .movie ? "FİLM" : "DİZİ").font(.caption.bold()).tracking(2).foregroundStyle(CineTheme.accent)
                    Text(movie.displayTitle).font(.cineTitle).fixedSize(horizontal: false, vertical: true)
                    if movie.original != movie.displayTitle { Text(movie.original).font(.subheadline).foregroundStyle(.secondary) }
                    if !movie.year.isEmpty { Text(movie.year).font(.subheadline).foregroundStyle(.secondary) }
                }
            }.padding(.horizontal, 20)
        }
    }
    private var metadata: some View {
        VStack(alignment: .leading, spacing: 16) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 16) { facts }
                VStack(alignment: .leading, spacing: 10) { facts }
            }.font(.subheadline).foregroundStyle(.secondary)
            if let genres = model.detail?.genres, !genres.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack { ForEach(genres) { Text($0.name).font(.caption.weight(.medium)).padding(.horizontal, 12).padding(.vertical, 8).background(CineTheme.surface, in: Rectangle()) } }
                }
            }
        }
    }
    @ViewBuilder private var facts: some View {
        if let vote = movie.voteAverage, vote > 0 {
            Label("\(vote.formatted(.number.precision(.fractionLength(1)))) / 10 · TMDB", systemImage: "star.fill").foregroundStyle(CineTheme.accent)
        }
        if let runtime = model.detail?.runtime ?? model.detail?.episodeRunTime?.first, runtime > 0 { Label("\(runtime) dk", systemImage: "clock") }
        if let seasons = model.detail?.numberOfSeasons { Label("\(seasons) sezon", systemImage: "rectangle.stack") }
    }
    private func rating(_ item: SavedTitle) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Senin puanın").font(.headline)
                Spacer()
                Text(item.rating.map { "\($0) / 10" } ?? "Henüz puan yok").font(.caption).foregroundStyle(.secondary)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 8)], spacing: 8) {
                ForEach(1...10, id: \.self) { value in
                    Button { storage.save(movie, status: item.status, rating: value) } label: {
                        Text("\(value)").font(.subheadline.weight(.semibold)).frame(maxWidth: .infinity, minHeight: 44)
                            .foregroundStyle(item.rating == value ? Color.black : .primary)
                            .background(item.rating == value ? CineTheme.accent : CineTheme.surface, in: Rectangle())
                    }.buttonStyle(.plain).accessibilityLabel("\(value) / 10 puan ver").accessibilityAddTraits(item.rating == value ? .isSelected : [])
                }
            }
            if item.rating != nil { Button("Puanı kaldır") { storage.save(movie, status: item.status) }.font(.caption).frame(minHeight: 44) }
        }
    }
    private var streaming: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack { Text("Nerede izlenir?").font(.cineHeading); Spacer(); Text("TR").font(.caption.bold()).foregroundStyle(.secondary) }
            if model.detail?.providersError == true || (model.error != nil && availability != nil) {
                Label("Yayın bilgisi yenilenemedi. Gösterilen seçenekler daha önce alınmış olabilir.", systemImage: "exclamationmark.triangle")
                    .font(.caption).foregroundStyle(CineTheme.accent)
                Button("Yayın bilgisini yenile") { Task { await model.load(movie) } }.font(.subheadline)
            }
            if let availability, !availability.all.isEmpty {
                offers("Abonelik", providers: availability.flatrate, subscription: true)
                offers("Kirala", providers: availability.rent)
                offers("Satın al", providers: availability.buy)
                if let link = availability.link, let url = URL(string: link), url.scheme == "https" {
                    Link(destination: url) {
                        HStack { Text("İzleme seçeneklerini aç"); Spacer(); Image(systemName: "arrow.up.right") }
                            .font(.subheadline.weight(.semibold)).frame(minHeight: 44)
                    }
                }
            } else if !model.loading && model.error == nil && model.detail?.providersError != true {
                Label("Türkiye için doğrulanmış yayın seçeneği bulunamadı.", systemImage: "tv.slash").font(.subheadline).foregroundStyle(.secondary)
            }
            Text("Kaynak: JustWatch. Kataloglar değişebilir; güncel koşulları yayın platformunda kontrol et.").font(.caption).foregroundStyle(.secondary)
        }.padding(20).background(CineTheme.surface, in: Rectangle())
            .overlay(Rectangle().strokeBorder(CineTheme.border))
    }
    @ViewBuilder private func offers(_ title: String, providers: [Provider]?, subscription: Bool = false) -> some View {
        if let providers, !providers.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(title.uppercased()).font(.caption2.weight(.bold)).tracking(1.5).foregroundStyle(.secondary)
                ForEach(providers) { provider in ProviderBadge(provider: provider, showsSubscription: subscription) }
            }
        }
    }
    @ViewBuilder private func cast(_ credits: Credits) -> some View {
        let directors = Array(Set(credits.crew.filter { $0.job == "Director" }.map(\.name))).sorted()
        if !directors.isEmpty {
            VStack(alignment: .leading, spacing: 8) { Text("Yönetmen").font(.headline); Text(directors.joined(separator: ", ")).foregroundStyle(.secondary) }
        }
        if !credits.cast.isEmpty {
            SectionHeading(title: "Oyuncular")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach(Array(credits.cast.prefix(25).enumerated()), id: \.offset) { _, person in
                        VStack(alignment: .leading, spacing: 7) {
                            PosterImage(path: person.profilePath, size: "w185").frame(width: 104, height: 136).clipShape(Rectangle())
                            Text(person.name).font(.subheadline.weight(.semibold))
                            if let character = person.character?.nonEmpty { Text(character).font(.caption).foregroundStyle(.secondary) }
                        }.frame(width: 104, alignment: .leading).accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }
}
