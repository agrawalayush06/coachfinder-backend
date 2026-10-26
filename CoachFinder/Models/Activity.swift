import Foundation

struct Activity: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let category: String
}
