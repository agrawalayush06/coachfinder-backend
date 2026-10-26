import Foundation

protocol ProviderServiceProtocol: Sendable {
    func fetchProviders(
        city: String?,
        activityId: Int?,
        type: String?,
        lat: Double?,
        lng: Double?,
        radiusKm: Double?,
        sortBy: String?,
        page: Int,
        size: Int
    ) async throws -> PageResponse<Provider>

    func fetchProviderById(id: Int) async throws -> Provider
    func fetchActivities() async throws -> [Activity]
}

extension ProviderServiceProtocol {
    func fetchProviders(
        city: String? = nil,
        activityId: Int? = nil,
        type: String? = nil,
        lat: Double? = nil,
        lng: Double? = nil,
        radiusKm: Double? = nil,
        sortBy: String? = nil,
        page: Int = 0,
        size: Int = 20
    ) async throws -> PageResponse<Provider> {
        try await fetchProviders(
            city: city,
            activityId: activityId,
            type: type,
            lat: lat,
            lng: lng,
            radiusKm: radiusKm,
            sortBy: sortBy,
            page: page,
            size: size
        )
    }

    func fetchProviders(
        city: String?,
        activityId: Int?,
        page: Int,
        size: Int
    ) async throws -> PageResponse<Provider> {
        try await fetchProviders(
            city: city,
            activityId: activityId,
            type: nil,
            lat: nil,
            lng: nil,
            radiusKm: nil,
            sortBy: nil,
            page: page,
            size: size
        )
    }
}

final class ProviderService: ProviderServiceProtocol, Sendable {
    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func fetchProviders(
        city: String? = nil,
        activityId: Int? = nil,
        type: String? = nil,
        lat: Double? = nil,
        lng: Double? = nil,
        radiusKm: Double? = nil,
        sortBy: String? = nil,
        page: Int = 0,
        size: Int = 20
    ) async throws -> PageResponse<Provider> {
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
        if let type = type, !type.isEmpty && type != "ALL" {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }
        if let lat = lat {
            queryItems.append(URLQueryItem(name: "lat", value: String(lat)))
        }
        if let lng = lng {
            queryItems.append(URLQueryItem(name: "lng", value: String(lng)))
        }
        if let radiusKm = radiusKm {
            queryItems.append(URLQueryItem(name: "radiusKm", value: String(radiusKm)))
        }
        if let sortBy = sortBy, !sortBy.isEmpty {
            queryItems.append(URLQueryItem(name: "sortBy", value: sortBy))
        }

        return try await apiClient.request("v1/providers", queryItems: queryItems)
    }

    func fetchProviderById(id: Int) async throws -> Provider {
        return try await apiClient.request("v1/providers/\(id)")
    }

    func fetchActivities() async throws -> [Activity] {
        return try await apiClient.request("v1/activities")
    }
}
