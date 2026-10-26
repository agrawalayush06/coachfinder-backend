import Foundation

public struct PageResponse<T: Codable>: Codable {
    public let content: [T]
    public let number: Int
    public let size: Int
    public let totalElements: Int
    public let totalPages: Int
    public let first: Bool
    public let last: Bool
    public let empty: Bool

    public init(
        content: [T],
        number: Int = 0,
        size: Int = 20,
        totalElements: Int = 0,
        totalPages: Int = 1,
        first: Bool = true,
        last: Bool = true,
        empty: Bool = false
    ) {
        self.content = content
        self.number = number
        self.size = size
        self.totalElements = totalElements
        self.totalPages = totalPages
        self.first = first
        self.last = last
        self.empty = empty
    }
}
