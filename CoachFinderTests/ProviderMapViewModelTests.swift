import Testing
import CoreLocation
#if canImport(CoachFinderCore)
@testable import CoachFinderCore
#elseif canImport(Coach_finder)
@testable import Coach_finder
#endif

@Suite("ProviderMapViewModel Tests")
@MainActor
struct ProviderMapViewModelTests {
    private let mockService = MockProviderService()

    private func makeViewModel() -> ProviderMapViewModel {
        ProviderMapViewModel(providerService: mockService)
    }

    private func makeProvider(id: Int, lat: Double?, lng: Double?) -> Provider {
        Provider(
            id: id,
            userId: id,
            type: "COACH",
            name: "Coach \(id)",
            city: "London",
            lat: lat,
            lng: lng,
            createdAt: nil,
            updatedAt: nil
        )
    }

    @Test("providersWithCoordinates filters out providers with nil latitude or longitude")
    func testFilterCoordinates() {
        let vm = makeViewModel()
        let withCoords = makeProvider(id: 1, lat: 51.5, lng: -0.1)
        let noLat = makeProvider(id: 2, lat: nil, lng: -0.1)
        let noLng = makeProvider(id: 3, lat: 51.5, lng: nil)
        let noCoords = makeProvider(id: 4, lat: nil, lng: nil)

        vm.setProviders([withCoords, noLat, noLng, noCoords])

        #expect(vm.providers.count == 4)
        #expect(vm.providersWithCoordinates.count == 1)
        #expect(vm.providersWithCoordinates.first?.id == 1)
    }

    @Test("setProviders updates state without network calls")
    func testSetProvidersSharedData() {
        let vm = makeViewModel()
        let p1 = makeProvider(id: 10, lat: 51.5, lng: -0.1)
        let p2 = makeProvider(id: 20, lat: 52.0, lng: -0.2)

        vm.setProviders([p1, p2])

        #expect(mockService.fetchProvidersCallCount == 0)
        #expect(vm.providers.count == 2)
        #expect(vm.providersWithCoordinates.count == 2)
    }

    @Test("selectProvider updates selectedProviderId and selectedProvider")
    func testSelectProvider() {
        let vm = makeViewModel()
        let p1 = makeProvider(id: 10, lat: 51.5, lng: -0.1)
        vm.setProviders([p1])

        #expect(vm.selectedProvider == nil)

        vm.selectProvider(p1)

        #expect(vm.selectedProviderId == 10)
        #expect(vm.selectedProvider?.id == 10)
    }

    @Test("loadProviders loads from service when providers is empty")
    func testLoadProvidersNetwork() async {
        let vm = makeViewModel()
        let p1 = makeProvider(id: 1, lat: 51.5, lng: -0.1)
        mockService.mockPageResponse = PageResponse(
            content: [p1],
            number: 0,
            size: 100,
            totalElements: 1,
            totalPages: 1,
            first: true,
            last: true,
            empty: false
        )

        await vm.loadProviders()

        #expect(mockService.fetchProvidersCallCount == 1)
        #expect(vm.providers.count == 1)
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test("loadProviders handles error properly")
    func testLoadProvidersError() async {
        let vm = makeViewModel()
        mockService.shouldThrowError = APIError.networkError(URLError(.timedOut))

        await vm.loadProviders()

        #expect(vm.isLoading == false)
        #expect(vm.errorMessage != nil)
        #expect(vm.providers.isEmpty == true)
    }
}
