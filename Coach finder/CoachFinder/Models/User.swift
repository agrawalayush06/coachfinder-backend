import Foundation

public struct User: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let email: String
    public let name: String
    public let role: String
    public let createdAt: String?

    public init(id: Int, email: String, name: String, role: String, createdAt: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role
        self.createdAt = createdAt
    }
}
