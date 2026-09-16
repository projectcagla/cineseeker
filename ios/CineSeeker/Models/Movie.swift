import Foundation

enum MediaType: String, Codable, CaseIterable, Sendable, Identifiable {
    case movie, tv
    var id: String { rawValue }
    var title: String { self == .movie ? "Filmler" : "Diziler" }
}
struct Movie: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    var title: String?
    var name: String?
    var originalTitle: String?
    var originalName: String?
    var posterPath: String?
    var backdropPath: String?
    var overview: String?
    var releaseDate: String?
    var firstAirDate: String?
    var voteAverage: Double?
    var genreIds: [Int]?
    var mediaType: MediaType?
    var providersTr: Availability?
    var providersError: Bool?
    var displayTitle: String { title ?? name ?? "İsimsiz içerik" }
    var original: String { originalTitle ?? originalName ?? displayTitle }
    var year: String { String((releaseDate ?? firstAirDate ?? "").prefix(4)) }
    var kind: MediaType { mediaType ?? (name == nil ? .movie : .tv) }
    var key: String { "\(kind.rawValue):\(id)" }
}
struct MoviePage: Decodable, Sendable { let results: [Movie]; let page: Int; let totalPages: Int }
struct Genre: Codable, Identifiable, Hashable, Sendable { let id: Int; let name: String }
struct GenrePage: Decodable, Sendable { let genres: [Genre] }
