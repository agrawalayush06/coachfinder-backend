import Foundation

struct APIErrorResponse: Codable, Error, LocalizedError {
    let timestamp: String?
    let status: Int?
    let message: String?
    let fieldErrors: [FieldError]?

    var errorDescription: String? {
        return message ?? "An unexpected error occurred."
    }
}

struct FieldError: Codable {
    let field: String
    let message: String
}
