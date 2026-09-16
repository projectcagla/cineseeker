import Foundation
enum WatchStatus: String, Codable, CaseIterable, Sendable, Identifiable {
    case want, watching, watched
    var id: String { rawValue }
    var title: String {
        switch self { case .want: "İzlemek İstiyorum"; case .watching: "İzliyorum"; case .watched: "İzledim" }
    }
    var icon: String {
        switch self { case .want: "bookmark"; case .watching: "play.circle"; case .watched: "checkmark.circle" }
    }
}
struct RemoteItem: Codable, Sendable {
    let tmdbId: Int
    let mediaType: MediaType
    let title: String
    let posterPath: String?
    let voteAverage: String?
    let releaseYear: String?
    let status: WatchStatus
    let rating: Int?
    var movie: Movie {
        Movie(id: tmdbId, title: title, posterPath: posterPath, releaseDate: releaseYear,
              voteAverage: Double(voteAverage ?? ""), mediaType: mediaType)
    }
}
struct RemoteProvider: Decodable, Sendable {
    let providerId: Int
    let providerName: String
    let logoPath: String?
    var provider: Provider { Provider(providerId: providerId, providerName: providerName, logoPath: logoPath) }
}
struct RemoteLibrary: Decodable, Sendable { let watchlist: [RemoteItem]; let providers: [RemoteProvider] }
