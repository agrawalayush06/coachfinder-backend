import Testing
#if canImport(CoachFinderCore)
@testable import CoachFinderCore
#elseif canImport(Coach_finder)
@testable import Coach_finder
#endif

@Suite("ProviderListViewModel Tests")
@MainActor
struct ProviderListViewModelTests {
    private let mockService = MockProviderService()

    private func makeViewModel() -> ProviderListViewModel {
        ProviderListViewModel(providerService: mockService)
    }

    private func sampleProvider(id: Int, name: String = "Test Coach", city: String = "London") -> Provider {
        Provider(
            id: id,
            userId: id * 10,
            type: "COACH",
            name: name,
            city: city,
            lat: 51.5,
            lng: -0.1,
            createdAt: nil,
            updatedAt: nil
        )
    }

    @Test("loadInitialData fetches activities and first page of providers")
    func testLoadInitialDataSuccess() async {
        let vm = makeViewModel()
        let provider1 = sampleProvider(id: 1)
        mockService.mockActivities = [Activity(id: 1, name: "Cricket", category: "Sports")]
        mockService.mockPageResponse = PageResponse(
            content: [provider1],
            number: 0,
            size: 20,
            totalElements: 1,
            totalPages: 1,
            first: true,
            last: true,
            empty: false
        )

        await vm.loadInitialData()

        #expect(mockService.fetchActivitiesCalled == true)
        #expect(mockService.fetchProvidersCallCount == 1)
        #expect(vm.activities.count == 1)
        #expect(vm.activities.first?.name == "Cricket")
        #expect(vm.providers.count == 1)
        #expect(vm.providers.first?.id == 1)
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
        #expect(vm.currentPage == 0)
        #expect(vm.totalPages == 1)
        #expect(vm.totalElements == 1)
    }

    @Test("selectActivity filters providers by activity ID and resets page to 0")
    func testSelectActivity() async {
        let vm = makeViewModel()
        let activity = Activity(id: 42, name: "Yoga", category: "Fitness")
        mockService.mockPageResponse = PageResponse(
            content: [sampleProvider(id: 2)],
            number: 0,
            size: 20,
            totalElements: 1,
            totalPages: 1,
            first: true,
            last: true,
            empty: false
        )

        await vm.selectActivity(activity)

        #expect(vm.selectedActivity == activity)
        #expect(mockService.lastFetchActivityId == 42)
        #expect(mockService.lastFetchPage == 0)
        #expect(vm.providers.count == 1)
    }

    @Test("searchCity queries backend with trimmed city name and resets page to 0")
    func testSearchCity() async {
        let vm = makeViewModel()
        vm.citySearchQuery = "  Delhi  "
        mockService.mockPageResponse = PageResponse(
            content: [sampleProvider(id: 3, city: "Delhi")],
            number: 0,
            size: 20,
            totalElements: 1,
            totalPages: 1,
            first: true,
            last: true,
            empty: false
        )

        await vm.searchCity()

        #expect(mockService.lastFetchCity == "Delhi")
        #expect(mockService.lastFetchPage == 0)
        #expect(vm.providers.count == 1)
    }

    @Test("loadMoreIfNeeded fetches next page and appends providers")
    func testLoadMorePagination() async {
        let vm = makeViewModel()
        let provider1 = sampleProvider(id: 1)
        let provider2 = sampleProvider(id: 2)

        // Initial page 0
        mockService.mockPageResponse = PageResponse(
            content: [provider1],
            number: 0,
            size: 1,
            totalElements: 2,
            totalPages: 2,
            first: true,
            last: false,
            empty: false
        )
        await vm.loadInitialData()
        #expect(vm.providers.count == 1)
        #expect(vm.hasMorePages == true)

        // Setup page 1 response
        mockService.mockPageResponse = PageResponse(
            content: [provider2],
            number: 1,
            size: 1,
            totalElements: 2,
            totalPages: 2,
            first: false,
            last: true,
            empty: false
        )

        await vm.loadMoreIfNeeded(currentProvider: provider1)

        #expect(mockService.fetchProvidersCallCount == 2)
        #expect(mockService.lastFetchPage == 1)
        #expect(vm.providers.count == 2)
        #expect(vm.providers.map { $0.id } == [1, 2])
        #expect(vm.currentPage == 1)
        #expect(vm.hasMorePages == false)
    }

    @Test("loadInitialData handles backend errors cleanly")
    func testLoadInitialDataError() async {
        let vm = makeViewModel()
        mockService.shouldThrowError = APIError.serverError(message: "Internal Server Error 500")

        await vm.loadInitialData()

        #expect(vm.isLoading == false)
        #expect(vm.providers.isEmpty == true)
        #expect(vm.errorMessage == "Internal Server Error 500")
        #expect(vm.isEmpty == false)
    }

    @Test("refresh updates provider list and resets status")
    func testRefresh() async {
        let vm = makeViewModel()
        mockService.mockPageResponse = PageResponse(
            content: [sampleProvider(id: 10)],
            number: 0,
            size: 20,
            totalElements: 1,
            totalPages: 1,
            first: true,
            last: true,
            empty: false
        )

        await vm.refresh()

        #expect(vm.isRefreshing == false)
        #expect(vm.providers.count == 1)
        #expect(vm.providers.first?.id == 10)
    }
}
