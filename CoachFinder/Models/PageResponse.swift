import Foundation

struct PageResponse<T: Codable>: Codable {
    let content: [T]
    let number: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let first: Bool
    let last: Bool
    let empty: Bool
}
