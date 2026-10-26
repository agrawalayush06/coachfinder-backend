import Testing
#if canImport(CoachFinderCore)
@testable import CoachFinderCore
#elseif canImport(Coach_finder)
@testable import Coach_finder
#endif

@Suite("ProviderDetailViewModel Tests")
@MainActor
struct ProviderDetailViewModelTests {
    private let mockService = MockProviderService()

    private func sampleProvider(id: Int = 101) -> Provider {
        Provider(
            id: id,
            userId: 55,
            type: "ACADEMY",
            name: "Pro Tennis Club",
            city: "Manchester",
            lat: 53.4808,
            lng: -2.2426,
            createdAt: "2026-10-01T12:00:00Z",
            updatedAt: "2026-10-02T12:00:00Z"
        )
    }

    @Test("loadDetails successfully fetches provider by ID")
    func testLoadDetailsSuccess() async {
        let expected = sampleProvider(id: 101)
        mockService.mockProvider = expected

        let vm = ProviderDetailViewModel(providerId: 101, providerService: mockService)
        #expect(vm.provider == nil)
        #expect(vm.isLoading == false)

        await vm.loadDetails()

        #expect(mockService.fetchProviderByIdCalledWithId == 101)
        #expect(vm.provider == expected)
        #expect(vm.provider?.name == "Pro Tennis Club")
        #expect(vm.provider?.city == "Manchester")
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test("loadDetails preserves initialProvider and updates on success")
    func testLoadDetailsWithInitialProvider() async {
        let initial = sampleProvider(id: 101)
        let updated = Provider(
            id: 101,
            userId: 55,
            type: "ACADEMY",
            name: "Pro Tennis Club (Updated)",
            city: "Manchester",
            lat: 53.4808,
            lng: -2.2426,
            createdAt: nil,
            updatedAt: nil
        )
        mockService.mockProvider = updated

        let vm = ProviderDetailViewModel(providerId: 101, initialProvider: initial, providerService: mockService)
        #expect(vm.provider?.name == "Pro Tennis Club")

        await vm.loadDetails()

        #expect(vm.provider?.name == "Pro Tennis Club (Updated)")
        #expect(vm.errorMessage == nil)
    }

    @Test("loadDetails records errorMessage when service throws 404")
    func testLoadDetailsFailure() async {
        mockService.shouldThrowError = APIError.serverError(message: "Provider not found")

        let vm = ProviderDetailViewModel(providerId: 999, providerService: mockService)
        await vm.loadDetails()

        #expect(vm.provider == nil)
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == "Provider not found")
    }
}
