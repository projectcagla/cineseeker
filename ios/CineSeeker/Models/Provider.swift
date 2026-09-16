import Foundation
struct Provider: Codable, Identifiable, Hashable, Sendable {
    let providerId: Int
    let providerName: String
    let logoPath: String?
    var id: Int { providerId }
}
struct ProviderPage: Decodable, Sendable { let results: [Provider] }
struct Availability: Codable, Hashable, Sendable {
    var link: String?
    var flatrate: [Provider]?
    var rent: [Provider]?
    var buy: [Provider]?
    var all: [Provider] {
        var seen = Set<Int>()
        return ((flatrate ?? []) + (rent ?? []) + (buy ?? [])).filter { seen.insert($0.id).inserted }
    }
}
