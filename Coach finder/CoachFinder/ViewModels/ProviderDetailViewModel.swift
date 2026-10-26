import Foundation
import Observation

/// The ViewModel for the Provider Detail screen.
/// Marked with `@MainActor` to ensure all UI updates happen safely on the main thread.
/// Uses the iOS 17+ `@Observable` macro.
@Observable
@MainActor
final class ProviderDetailViewModel {
    private let providerService: ProviderServiceProtocol
    let providerId: Int

    // State
    var provider: Provider?
    var isLoading: Bool = false
    var errorMessage: String? = nil

    init(
        providerId: Int,
        initialProvider: Provider? = nil,
        providerService: ProviderServiceProtocol = ProviderService()
    ) {
        self.providerId = providerId
        self.provider = initialProvider
        self.providerService = providerService
    }

    /// Fetches the latest provider details from `GET /v1/providers/{id}`.
    func loadDetails() async {
        // If we don't have provider data yet, show full loading state
        if provider == nil {
            isLoading = true
        }
        errorMessage = nil

        do {
            let fetched = try await providerService.fetchProviderById(id: providerId)
            self.provider = fetched
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }
}
