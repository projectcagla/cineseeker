import Foundation
struct MovieDetail: Decodable, Sendable {
    let id: Int
    let overview: String?
    let runtime: Int?
    let episodeRunTime: [Int]?
    let numberOfSeasons: Int?
    let genres: [Genre]
    let credits: Credits?
    var providersTr: Availability?
}
struct Credits: Decodable, Sendable { let cast: [Person]; let crew: [Person] }
struct Person: Decodable, Identifiable, Sendable {
    let id: Int
    let name: String
    let profilePath: String?
    let character: String?
    let job: String?
}
