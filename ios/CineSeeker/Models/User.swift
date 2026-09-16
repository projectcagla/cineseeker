import Foundation
struct User: Codable, Sendable { let id: String; var name: String; let email: String }
struct SessionResponse: Decodable, Sendable { let user: User }
