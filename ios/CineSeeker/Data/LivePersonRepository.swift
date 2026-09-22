import Foundation

extension LiveCatalogRepository: PersonRepository {
    func person(id: Int, language: String = "tr-TR", includingCredits: Bool = true) async throws -> PersonProfile {
        var query = ["language": language]
        if includingCredits { query["append_to_response"] = "combined_credits" }
        return try await network.request(.init(path: "person/\(id)", query: query))
    }
}
