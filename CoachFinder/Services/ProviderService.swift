import Foundation

protocol ProviderServiceProtocol: Sendable {
    func fetchProviders(city: String?, activityId: Int?, page: Int, size: Int) async throws -> PageResponse<Provider>
    func fetchProviderById(id: Int) async throws -> Provider
    func fetchActivities() async throws -> [Activity]
}

final class ProviderService: ProviderServiceProtocol, Sendable {
    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func fetchProviders(city: String? = nil, activityId: Int? = nil, page: Int = 0, size: Int = 20) async throws -> PageResponse<Provider> {
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size))
        ]
        if let city = city, !city.trimmingCharacters(in: .whitespaces).isEmpty {
            queryItems.append(URLQueryItem(name: "city", value: city.trimmingCharacters(in: .whitespaces)))
        }
        if let activityId = activityId {
            queryItems.append(URLQueryItem(name: "activityId", value: String(activityId)))
        }

        return try await apiClient.request("providers", queryItems: queryItems)
    }

    func fetchProviderById(id: Int) async throws -> Provider {
        return try await apiClient.request("providers/\(id)")
    }

    func fetchActivities() async throws -> [Activity] {
        return try await apiClient.request("activities")
    }
}
