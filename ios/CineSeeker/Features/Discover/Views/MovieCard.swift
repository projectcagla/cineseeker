import SwiftUI
struct ProviderBadge: View {
    let provider: Provider
    @Environment(StorageManager.self) private var storage
    var body: some View {
        HStack(spacing: 6) {
            PosterImage(path: provider.logoPath, size: "w92").frame(width: 24, height: 24).clipShape(RoundedRectangle(cornerRadius: 6))
            VStack(alignment: .leading, spacing: 1) {
                Text(provider.providerName).font(.caption).lineLimit(1)
                if storage.isSubscribed(provider) { Text("Abonesiniz").font(.caption2).foregroundStyle(.green) }
            }
        }.padding(5).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(storage.isSubscribed(provider) ? .green.opacity(0.8) : .clear))
            .shadow(color: storage.isSubscribed(provider) ? .green.opacity(0.16) : .clear, radius: 5)
            .accessibilityElement(children: .combine)
    }
}
struct WatchMenu: View {
    let movie: Movie
    var compact = false
    @Environment(StorageManager.self) private var storage
    var body: some View {
        Menu {
            ForEach(WatchStatus.allCases) { status in
                Button { storage.save(movie, status: status, rating: storage.item(movie)?.rating) } label: { Label(status.title, systemImage: status.icon) }
            }
            if storage.item(movie) != nil { Button("Listeden Çıkar", role: .destructive) { storage.remove(movie) } }
        } label: {
            Label(storage.item(movie) == nil ? "Listeme Ekle" : "Listede", systemImage: storage.item(movie) == nil ? "bookmark" : "bookmark.fill")
                .labelStyle(.titleAndIcon)
                .font(compact ? .caption : .headline)
                .padding(compact ? 10 : 14)
                .background(compact ? Color.black.opacity(0.7) : CineTheme.accent.opacity(0.2), in: Capsule())
        }.accessibilityLabel("\(movie.displayTitle), \(storage.item(movie)?.status.title ?? "Listeme ekle")")
    }
}
struct MovieCard: View {
    let movie: Movie
    @Environment(StorageManager.self) private var storage
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            ZStack(alignment: .top) {
                NavigationLink(value: movie) {
                    PosterImage(path: movie.posterPath).aspectRatio(2/3, contentMode: .fit)
                        .overlay(alignment: .bottom) { LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom) }
                }.accessibilityLabel("\(movie.displayTitle), \(movie.year), ayrıntılar")
                HStack(alignment: .top) {
                    Menu {
                        ForEach(WatchStatus.allCases) { status in Button(status.title) { storage.save(movie, status: status, rating: storage.item(movie)?.rating) } }
                        if storage.item(movie) != nil { Button("Listeden Çıkar", role: .destructive) { storage.remove(movie) } }
                    } label: {
                        Image(systemName: storage.item(movie) == nil ? "bookmark" : "bookmark.fill")
                            .frame(width: 44, height: 44).background(.black.opacity(0.7), in: Circle())
                    }.accessibilityLabel("\(movie.displayTitle), liste durumunu değiştir")
                    Spacer(minLength: 2)
                    if let vote = movie.voteAverage, vote > 0 {
                        Label(vote.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill")
                            .font(.caption.bold()).foregroundStyle(.yellow).padding(8).background(.black.opacity(0.8), in: Capsule())
                            .accessibilityLabel("TMDB puanı \(vote.formatted(.number.precision(.fractionLength(1)))) / 10")
                    }
                }.padding(7)
            }.clipShape(RoundedRectangle(cornerRadius: 18))
            NavigationLink(value: movie) { Text(movie.displayTitle).font(.headline).foregroundStyle(.primary).lineLimit(2).frame(maxWidth: .infinity, alignment: .leading) }
            HStack {
                Text(movie.year).foregroundStyle(.secondary)
                if let rating = storage.item(movie)?.rating { Spacer(); Label("\(rating)", systemImage: "star.fill").foregroundStyle(CineTheme.accent) }
            }.font(.caption)
            if let providers = movie.providersTr?.flatrate, !providers.isEmpty {
                ProviderBadge(provider: providers.sorted { storage.isSubscribed($0) && !storage.isSubscribed($1) }.first!)
            } else if movie.providersError == true { Text("Platform bilgisi alınamadı").font(.caption2).foregroundStyle(.secondary) }
        }
    }
}
struct MovieGrid: View {
    let movies: [Movie]
    @Environment(\.dynamicTypeSize) private var typeSize
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: typeSize.isAccessibilitySize ? 280 : 150), spacing: 16)], alignment: .leading, spacing: 24) {
            ForEach(movies, id: \.key) { MovieCard(movie: $0) }
        }
    }
}
