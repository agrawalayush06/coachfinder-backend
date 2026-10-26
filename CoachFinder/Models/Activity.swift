import Foundation

public struct Activity: Codable, Identifiable, Equatable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let category: String

    public init(id: Int, name: String, category: String) {
        self.id = id
        self.name = name
        self.category = category
    }
}
