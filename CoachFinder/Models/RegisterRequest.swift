import Foundation

public struct RegisterRequest: Codable, Sendable {
    public let email: String
    public let password: String
    public let name: String
    public let role: String

    public init(email: String, password: String, name: String, role: String) {
        self.email = email
        self.password = password
        self.name = name
        self.role = role
    }
}
