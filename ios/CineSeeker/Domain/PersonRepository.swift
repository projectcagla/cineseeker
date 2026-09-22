import Foundation

protocol PersonRepository: Sendable {
    func person(id: Int, language: String, includingCredits: Bool) async throws -> PersonProfile
}
