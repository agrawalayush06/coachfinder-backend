import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case serverError(message: String)
    case decodingError
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL."
        case .serverError(let message):
            return message
        case .decodingError:
            return "Failed to process data received from server."
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

final class APIClient: Sendable {
    static let shared = APIClient()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: String, queryItems: [URLQueryItem] = []) async throws -> T {
        guard var components = URLComponents(url: AppConfig.baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: true) else {
            throw APIError.invalidURL
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(message: "Invalid response from server.")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
               let message = errorResponse.message, !message.isEmpty {
                throw APIError.serverError(message: message)
            }
            throw APIError.serverError(message: "Server returned error code \(httpResponse.statusCode).")
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
}
