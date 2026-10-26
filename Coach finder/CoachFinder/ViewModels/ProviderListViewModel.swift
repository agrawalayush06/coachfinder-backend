import Foundation
import Observation

/// The ViewModel for the Provider List screen.
/// Marked with `@MainActor` to ensure all UI state updates happen on the main thread.
/// Uses the iOS 17+ `@Observable` macro for automatic SwiftUI view updates.
@Observable
@MainActor
final class ProviderListViewModel {
    private let providerService: ProviderServiceProtocol

    // MARK: - State Properties
    var providers: [Provider] = []
    var activities: [Activity] = []
    var selectedActivity: Activity? = nil
    var citySearchQuery: String = ""

    // MARK: - UI Status
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var isRefreshing: Bool = false
    var errorMessage: String? = nil

    // MARK: - Pagination State
    private(set) var currentPage: Int = 0
    private(set) var totalPages: Int = 0
    private(set) var totalElements: Int = 0
    let pageSize: Int = 20

    var hasMorePages: Bool {
        currentPage + 1 < totalPages
    }

    var isEmpty: Bool {
        !isLoading && providers.isEmpty && errorMessage == nil
    }

    // MARK: - Initializer
    init(providerService: ProviderServiceProtocol = ProviderService()) {
        self.providerService = providerService
    }

    // MARK: - Actions

    /// Loads initial activities and the first page of providers in parallel.
    func loadInitialData() async {
        guard providers.isEmpty && activities.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            async let fetchedActivities = providerService.fetchActivities()
            async let fetchedPage = providerService.fetchProviders(
                city: sanitizedCity,
                activityId: selectedActivity?.id,
                page: 0,
                size: pageSize
            )

            let (acts, page) = try await (fetchedActivities, fetchedPage)
            self.activities = acts
            self.providers = page.content
            self.currentPage = page.number
            self.totalPages = page.totalPages
            self.totalElements = page.totalElements
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    /// Pull-to-refresh: refreshes both activities and the first page of providers.
    func refresh() async {
        isRefreshing = true
        errorMessage = nil

        do {
            async let fetchedActivities = providerService.fetchActivities()
            async let fetchedPage = providerService.fetchProviders(
                city: sanitizedCity,
                activityId: selectedActivity?.id,
                page: 0,
                size: pageSize
            )

            let (acts, page) = try await (fetchedActivities, fetchedPage)
            self.activities = acts
            self.providers = page.content
            self.currentPage = page.number
            self.totalPages = page.totalPages
            self.totalElements = page.totalElements
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isRefreshing = false
    }

    /// User taps an activity filter pill (or "All" if activity is nil).
    func selectActivity(_ activity: Activity?) async {
        guard selectedActivity != activity else { return }
        selectedActivity = activity
        await fetchFirstPage()
    }

    /// User submits a city search or clears the search bar.
    func searchCity() async {
        await fetchFirstPage()
    }

    /// Resets page to 0 and queries the backend with current filters.
    private func fetchFirstPage() async {
        isLoading = true
        errorMessage = nil
        currentPage = 0

        do {
            let page = try await providerService.fetchProviders(
                city: sanitizedCity,
                activityId: selectedActivity?.id,
                page: 0,
                size: pageSize
            )
            self.providers = page.content
            self.currentPage = page.number
            self.totalPages = page.totalPages
            self.totalElements = page.totalElements
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    /// Triggers pagination when the user scrolls near the bottom of the list.
    func loadMoreIfNeeded(currentProvider: Provider) async {
        guard let lastProvider = providers.last,
              lastProvider.id == currentProvider.id,
              hasMorePages,
              !isLoading,
              !isLoadingMore else {
            return
        }

        isLoadingMore = true
        let nextPage = currentPage + 1

        do {
            let page = try await providerService.fetchProviders(
                city: sanitizedCity,
                activityId: selectedActivity?.id,
                page: nextPage,
                size: pageSize
            )
            self.providers.append(contentsOf: page.content)
            self.currentPage = page.number
            self.totalPages = page.totalPages
            self.totalElements = page.totalElements
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoadingMore = false
    }

    // MARK: - Helpers
    private var sanitizedCity: String? {
        let trimmed = citySearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
