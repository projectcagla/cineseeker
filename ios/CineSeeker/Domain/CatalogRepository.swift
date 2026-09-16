import Foundation
protocol CatalogRepository: Sendable {
    func feed(media: MediaType, mode: FeedMode, providers: [Int], page: Int) async throws -> MoviePage
    func search(_ query: String, media: MediaType, genre: Int?, page: Int) async throws -> MoviePage
    func detail(_ movie: Movie) async throws -> MovieDetail
    func providers() async throws -> [Provider]
    func genres(_ media: MediaType) async throws -> [Genre]
}
enum FeedMode: String, CaseIterable, Identifiable {
    case popular = "Yeni & Popüler", mine = "Platformlarım", arrivals = "Yeni Eklenenler"
    var id: String { rawValue }
}
