import SwiftUI

struct ProviderBadge: View {
    let provider: Provider
    var showsSubscription = true
    @Environment(StorageManager.self) private var storage
    var body: some View {
        HStack(spacing: 8) {
            PosterImage(path: provider.logoPath, size: "w92").frame(width: 28, height: 28).clipShape(RoundedRectangle(cornerRadius: 7))
            VStack(alignment: .leading, spacing: 2) {
                Text(provider.providerName).font(.caption.weight(.medium)).lineLimit(2)
                if showsSubscription && storage.isSubscribed(provider) {
                    Label("Abonesiniz", systemImage: "checkmark.seal.fill").font(.caption2).foregroundStyle(CineTheme.success)
                }
            }
        }.padding(7).background(CineTheme.surface, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(showsSubscription && storage.isSubscribed(provider) ? CineTheme.success.opacity(0.5) : CineTheme.border))
            .accessibilityElement(children: .combine)
    }
}
struct WatchMenu: View {
    let movie: Movie
    var compact = false
    @Environment(StorageManager.self) private var storage
    var body: some View {
        let saved = storage.item(movie)
        Menu {
            ForEach(WatchStatus.allCases) { status in
                Button { storage.save(movie, status: status, rating: saved?.rating) } label: {
                    Label(status.title, systemImage: saved?.status == status ? "checkmark" : status.icon)
                }
            }
            if saved != nil { Divider(); Button("Listeden Çıkar", role: .destructive) { storage.remove(movie) } }
        } label: {
            HStack(spacing: 9) {
                Image(systemName: saved?.status.icon ?? "bookmark")
                if !compact { Text(saved?.status.title ?? "Listeme Ekle"); Image(systemName: "chevron.down").font(.caption.bold()) }
            }.font(.subheadline.weight(.semibold))
                .frame(minWidth: 44, minHeight: 44)
                .padding(.horizontal, compact ? 0 : 16)
                .foregroundStyle(compact ? Color.white : Color.black)
                .background(compact ? Color.black.opacity(0.74) : CineTheme.accent, in: Capsule())
        }.accessibilityLabel("\(movie.displayTitle), \(saved?.status.title ?? "Listeme ekle")")
            .accessibilityHint("İzleme durumunu seç")
    }
}
struct MovieCard: View {
    let movie: Movie
    @Environment(StorageManager.self) private var storage
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .top) {
                NavigationLink(value: movie) {
                    PosterImage(path: movie.posterPath).aspectRatio(2.0/3, contentMode: .fit)
                        .overlay(alignment: .bottom) {
                            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
                        }
                }.buttonStyle(.plain).accessibilityLabel("\(movie.displayTitle), \(movie.year), ayrıntılar")
                HStack(alignment: .top) {
                    WatchMenu(movie: movie, compact: true)
                    Spacer(minLength: 0)
                    if let vote = movie.voteAverage, vote > 0 {
                        Label(vote.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill")
                            .font(.caption.weight(.bold)).foregroundStyle(.white)
                            .padding(.horizontal, 9).frame(minHeight: 32).background(.black.opacity(0.74), in: Capsule())
                            .accessibilityLabel("TMDB puanı \(vote.formatted(.number.precision(.fractionLength(1)))) / 10")
                    }
                }.padding(8)
            }.clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(CineTheme.border)).contentShape(RoundedRectangle(cornerRadius: 20))
            NavigationLink(value: movie) {
                Text(movie.displayTitle).font(.subheadline.weight(.semibold)).foregroundStyle(.primary)
                    .lineLimit(2, reservesSpace: true).frame(maxWidth: .infinity, alignment: .leading)
            }.buttonStyle(.plain)
            HStack(spacing: 6) {
                Text([movie.year.nonEmpty, movie.kind == .movie ? "Film" : "Dizi"].compactMap { $0 }.joined(separator: " · "))
                Spacer(minLength: 0)
                if let rating = storage.item(movie)?.rating { Label("\(rating)", systemImage: "star.fill").foregroundStyle(CineTheme.accent).accessibilityLabel("Puanın \(rating) / 10") }
            }.font(.caption).foregroundStyle(.secondary)
            if let saved = storage.item(movie) {
                Label(saved.status.title, systemImage: saved.status.icon).font(.caption2.weight(.medium)).foregroundStyle(CineTheme.accent)
            }
            if let availability = movie.providersTr, !availability.all.isEmpty {
                let providers = (availability.flatrate?.isEmpty == false ? availability.flatrate! : availability.all)
                    .sorted { storage.isSubscribed($0) && !storage.isSubscribed($1) }
                HStack(spacing: 5) {
                    ForEach(Array(providers.prefix(3))) { provider in
                        PosterImage(path: provider.logoPath, size: "w92").frame(width: 24, height: 24)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(availability.flatrate?.contains(where: { $0.id == provider.id }) == true && storage.isSubscribed(provider) ? CineTheme.success : .clear, lineWidth: 1.5))
                    }
                    if providers.count > 3 { Text("+\(providers.count - 3)").font(.caption2).foregroundStyle(.secondary) }
                    Spacer(minLength: 0)
                }.accessibilityElement(children: .ignore).accessibilityLabel(providers.map(\.providerName).joined(separator: ", "))
                if providers.contains(where: storage.isSubscribed), availability.flatrate?.isEmpty == false {
                    Text("Aboneliğinde").font(.caption2.weight(.medium)).foregroundStyle(CineTheme.success)
                } else if availability.flatrate?.isEmpty != false {
                    Text("Kirala / satın al").font(.caption2).foregroundStyle(.secondary)
                }
            } else if movie.providersError == true {
                Text("Platform bilgisi alınamadı").font(.caption2).foregroundStyle(.secondary)
            }
        }.frame(maxHeight: .infinity, alignment: .top)
    }
}
struct MovieGrid: View {
    let movies: [Movie]
    @Environment(\.dynamicTypeSize) private var typeSize
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: typeSize.isAccessibilitySize ? 280 : 150), spacing: 16, alignment: .top)], alignment: .leading, spacing: 28) {
            ForEach(movies, id: \.key) { MovieCard(movie: $0) }
        }
    }
}
