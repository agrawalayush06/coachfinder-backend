import Foundation
#if canImport(CoachFinderCore)
@testable import CoachFinderCore
#elseif canImport(Coach_finder)
@testable import Coach_finder
#endif

/// A configurable mock implementation of ProviderServiceProtocol for unit testing.
final class MockProviderService: ProviderServiceProtocol, @unchecked Sendable {
    // Configurable stubs
    var mockActivities: [Activity] = []
    var mockPageResponse: PageResponse<Provider> = PageResponse(
        content: [],
        number: 0,
        size: 20,
        totalElements: 0,
        totalPages: 0,
        first: true,
        last: true,
        empty: true
    )
    var mockProvider: Provider? = nil
    var shouldThrowError: Error? = nil

    // Spies for verifying calls
    private(set) var fetchActivitiesCalled = false
    private(set) var fetchProvidersCallCount = 0
    private(set) var lastFetchCity: String?
    private(set) var lastFetchActivityId: Int?
    private(set) var lastFetchType: String?
    private(set) var lastFetchLat: Double?
    private(set) var lastFetchLng: Double?
    private(set) var lastFetchRadiusKm: Double?
    private(set) var lastFetchSortBy: String?
    private(set) var lastFetchPage: Int?
    private(set) var lastFetchSize: Int?
    private(set) var fetchProviderByIdCalledWithId: Int?

    func fetchActivities() async throws -> [Activity] {
        fetchActivitiesCalled = true
        if let error = shouldThrowError {
            throw error
        }
        return mockActivities
    }

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
    ) async throws -> PageResponse<Provider> {
        fetchProvidersCallCount += 1
        lastFetchCity = city
        lastFetchActivityId = activityId
        lastFetchType = type
        lastFetchLat = lat
        lastFetchLng = lng
        lastFetchRadiusKm = radiusKm
        lastFetchSortBy = sortBy
        lastFetchPage = page
        lastFetchSize = size

        if let error = shouldThrowError {
            throw error
        }
        return mockPageResponse
    }

    func fetchProviders(city: String?, activityId: Int?, page: Int, size: Int) async throws -> PageResponse<Provider> {
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

    func fetchProviderById(id: Int) async throws -> Provider {
        fetchProviderByIdCalledWithId = id
        if let error = shouldThrowError {
            throw error
        }
        guard let provider = mockProvider else {
            throw APIError.serverError(message: "Provider not found")
        }
        return provider
    }
}
