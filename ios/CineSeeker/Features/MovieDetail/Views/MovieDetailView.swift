import SwiftUI
struct MovieDetailView: View {
    let movie: Movie
    @Environment(StorageManager.self) private var storage
    @State private var model = MovieDetailViewModel()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                ZStack(alignment: .bottomLeading) {
                    PosterImage(path: movie.backdropPath ?? movie.posterPath, size: "w780")
                    LinearGradient(colors: [.clear, CineTheme.background], startPoint: .top, endPoint: .bottom)
                    HStack(alignment: .bottom, spacing: 18) {
                        PosterImage(path: movie.posterPath).frame(width: 98, height: 147).clipShape(RoundedRectangle(cornerRadius: 14))
                        VStack(alignment: .leading, spacing: 8) {
                            Text(movie.kind.title.uppercased()).font(.caption.bold()).tracking(2).foregroundStyle(CineTheme.accent)
                            Text(movie.displayTitle).font(.cineHeading)
                            Text(movie.original).font(.subheadline).foregroundStyle(.secondary)
                            Text(movie.year).font(.subheadline)
                        }
                    }.padding(20)
                }.frame(minHeight: 330)
                VStack(alignment: .leading, spacing: 26) {
                    HStack {
                        if let vote = movie.voteAverage { Label(vote.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill").foregroundStyle(.yellow) }
                        if let runtime = model.detail?.runtime ?? model.detail?.episodeRunTime?.first, runtime > 0 { Text("\(runtime) dk") }
                        if let seasons = model.detail?.numberOfSeasons { Text("\(seasons) sezon") }
                    }.font(.subheadline).foregroundStyle(.secondary)
                    if let genres = model.detail?.genres {
                        ScrollView(.horizontal, showsIndicators: false) { HStack { ForEach(genres) { Text($0.name).font(.caption).padding(8).background(.thinMaterial, in: Capsule()) } } }
                    }
                    WatchMenu(movie: movie)
                    if let item = storage.item(movie) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Senin puanın").font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    ForEach(1...10, id: \.self) { rating in
                                        Button { storage.save(movie, status: item.status, rating: rating) } label: {
                                            VStack(spacing: 4) {
                                                Image(systemName: rating <= (item.rating ?? 0) ? "star.fill" : "star")
                                                Text("\(rating)").font(.caption2)
                                            }.frame(width: 44, height: 48).foregroundStyle(CineTheme.accent)
                                        }.accessibilityLabel("\(rating) / 10 puan ver").accessibilityAddTraits(item.rating == rating ? .isSelected : [])
                                    }
                                }
                            }
                            if item.rating != nil { Button("Puanı Kaldır") { storage.save(movie, status: item.status) }.font(.caption) }
                        }
                    }
                    if model.loading { ProgressView("Ayrıntılar yükleniyor…") }
                    if let error = model.error { StatusPanel(title: "Ayrıntılar alınamadı", message: error) { Task { await model.load(movie) } } }
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Nerede izlenir?").font(.cineHeading)
                        if let availability = model.detail?.providersTr ?? movie.providersTr, !availability.all.isEmpty {
                            offers("Abonelik", providers: availability.flatrate)
                            offers("Kirala", providers: availability.rent)
                            offers("Satın Al", providers: availability.buy)
                            if let link = availability.link, let url = URL(string: link), url.scheme == "https" {
                                Link(destination: url) { Label("Güncel izleme bağlantıları", systemImage: "arrow.up.right") }.font(.subheadline)
                            }
                        } else if !model.loading && model.error == nil { Text("Türkiye için doğrulanmış yayın seçeneği bulunamadı.").foregroundStyle(.secondary) }
                        Text("Yayın bilgileri JustWatch tarafından sağlanır. Kataloglar ve fiyatlar değişebilir.").font(.caption).foregroundStyle(.secondary)
                    }.padding(18).background(CineTheme.surface, in: RoundedRectangle(cornerRadius: 20))
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Hikâye").font(.cineHeading)
                        Text((model.detail?.overview ?? movie.overview)?.nonEmpty ?? "Türkçe özet henüz bulunmuyor.").foregroundStyle(.secondary).lineSpacing(5)
                    }
                    if let credits = model.detail?.credits {
                        let directors = credits.crew.filter { $0.job == "Director" }.map(\.name)
                        if !directors.isEmpty { VStack(alignment: .leading, spacing: 6) { Text("Yönetmen").font(.headline); Text(directors.joined(separator: ", ")).foregroundStyle(.secondary) } }
                        Text("Oyuncular").font(.cineHeading)
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(alignment: .top, spacing: 16) {
                                ForEach(Array(credits.cast.prefix(25))) { person in
                                    VStack(alignment: .leading, spacing: 6) {
                                        PosterImage(path: person.profilePath, size: "w185").frame(width: 100, height: 120).clipShape(RoundedRectangle(cornerRadius: 12))
                                        Text(person.name).font(.subheadline.bold())
                                        Text(person.character ?? "").font(.caption).foregroundStyle(.secondary)
                                    }.frame(width: 100, alignment: .leading)
                                }
                            }
                        }
                    }
                }.padding(.horizontal, 20).padding(.bottom, 30)
            }
        }.cineBackground().navigationBarTitleDisplayMode(.inline).task { await model.load(movie) }
    }
    @ViewBuilder private func offers(_ title: String, providers: [Provider]?) -> some View {
        if let providers, !providers.isEmpty {
            Text(title).font(.headline)
            ForEach(providers) { provider in
                HStack {
                    ProviderBadge(provider: provider)
                    Spacer()
                    if storage.isSubscribed(provider) { Label("Aboneliğiniz Var", systemImage: "checkmark.seal.fill").font(.caption).foregroundStyle(.green) }
                }
            }
        }
    }
}
