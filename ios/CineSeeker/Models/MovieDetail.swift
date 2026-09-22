import Foundation
struct MovieDetail: Decodable, Sendable {
    let id: Int
    let overview: String?
    let runtime: Int?
    let episodeRunTime: [Int]?
    let numberOfSeasons: Int?
    let genres: [Genre]
    let credits: Credits?
    var createdBy: [Person]?
    var recommendations: MoviePage?
    var videos: VideoPage?
    var providersTr: Availability?
    var providersError: Bool?
}
struct VideoPage: Decodable, Sendable { let results: [CatalogVideo] }
struct CatalogVideo: Decodable, Sendable {
    let key: String
    let site: String
    let type: String
    let official: Bool?
    let iso6391: String?
    var url: URL? {
        guard site == "YouTube", ["Trailer", "Teaser"].contains(type),
              !key.isEmpty, key.count <= 64,
              key.unicodeScalars.allSatisfy({ CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-").contains($0) }) else { return nil }
        var components = URLComponents(string: "https://www.youtube.com/watch")!
        components.queryItems = [URLQueryItem(name: "v", value: key)]
        return components.url
    }
}
struct Credits: Decodable, Sendable { let cast: [Person]; let crew: [Person] }
struct Person: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let profilePath: String?
    let character: String?
    let job: String?
}
