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

    func fetchProviders(city: String?, activityId: Int?, page: Int, size: Int) async throws -> PageResponse<Provider> {
        fetchProvidersCallCount += 1
        lastFetchCity = city
        lastFetchActivityId = activityId
        lastFetchPage = page
        lastFetchSize = size

        if let error = shouldThrowError {
            throw error
        }
        return mockPageResponse
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
