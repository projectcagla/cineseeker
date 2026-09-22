import Foundation

struct PersonRoute: Hashable {
    let person: Person
    var role: FilmographyRole = .all
}

struct PersonProfile: Decodable, Sendable {
    let id: Int
    let name: String
    let biography: String?
    let birthday: String?
    let deathday: String?
    let placeOfBirth: String?
    let knownForDepartment: String?
    let profilePath: String?
    let combinedCredits: PersonCredits?
}
struct PersonCredits: Decodable, Sendable {
    let cast: [PersonCredit]
    let crew: [PersonCredit]
}
struct PersonCredit: Decodable, Sendable {
    let movie: Movie
    let character: String?
    let job: String?
    let department: String?
    let popularity: Double?
    let adult: Bool?
    private enum CodingKeys: String, CodingKey { case character, job, department, popularity, adult }
    init(from decoder: any Decoder) throws {
        movie = try Movie(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        character = try values.decodeIfPresent(String.self, forKey: .character)
        job = try values.decodeIfPresent(String.self, forKey: .job)
        department = try values.decodeIfPresent(String.self, forKey: .department)
        popularity = try values.decodeIfPresent(Double.self, forKey: .popularity)
        adult = try values.decodeIfPresent(Bool.self, forKey: .adult)
    }
}
enum FilmographyRole: String, CaseIterable, Identifiable, Sendable {
    case all = "Tüm katkılar", acting = "Oyunculuk", directing = "Yönetmenlik", writing = "Senaryo", production = "Yapım", other = "Diğer"
    var id: String { rawValue }
    static func crewRole(_ credit: PersonCredit) -> Self {
        if credit.job == "Director" { return .directing }
        switch credit.department {
        case "Writing": return .writing
        case "Production": return .production
        default: return .other
        }
    }
}
enum FilmographySort: String, CaseIterable, Identifiable {
    case popular = "Öne çıkanlar", newest = "Yeniden eskiye", oldest = "Eskiden yeniye"
    var id: String { rawValue }
}
struct FilmographyEntry: Identifiable, Sendable {
    var movie: Movie
    var roles: Set<FilmographyRole>
    var characters: [String]
    var popularity: Double
    var id: String { movie.key }
    var contribution: String {
        let roles = FilmographyRole.allCases.filter { self.roles.contains($0) }.map(\.rawValue)
        let character = characters.first
        return (roles + (character.map { [$0] } ?? [])).joined(separator: " · ")
    }
    static func merged(_ credits: PersonCredits) -> [Self] {
        var entries: [String: Self] = [:]
        for (credit, role) in credits.cast.map({ ($0, FilmographyRole.acting) }) + credits.crew.map({ ($0, FilmographyRole.crewRole($0)) }) {
            guard credit.adult != true else { continue }
            var entry = entries[credit.movie.key] ?? Self(movie: credit.movie, roles: [], characters: [], popularity: credit.popularity ?? 0)
            entry.roles.insert(role)
            if let character = credit.character?.nonEmpty, !entry.characters.contains(character) { entry.characters.append(character) }
            entry.popularity = max(entry.popularity, credit.popularity ?? 0)
            entries[entry.id] = entry
        }
        return Array(entries.values)
    }
}
