import Foundation
import MapKit
import Observation
import SwiftUI

/// The ViewModel for the Provider Map screen.
/// Marked with `@MainActor` and `@Observable`.
@Observable
@MainActor
final class ProviderMapViewModel {
    private let providerService: ProviderServiceProtocol
    let locationManager: LocationManager

    // State
    var providers: [Provider] = []
    var cameraPosition: MapCameraPosition = .automatic
    var selectedProviderId: Int? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil

    // Computed properties
    var providersWithCoordinates: [Provider] {
        providers.filter { $0.coordinate != nil }
    }

    var selectedProvider: Provider? {
        guard let id = selectedProviderId else { return nil }
        return providers.first(where: { $0.id == id })
    }

    init(
        providerService: ProviderServiceProtocol? = nil,
        locationManager: LocationManager? = nil
    ) {
        self.providerService = providerService ?? ProviderService()
        self.locationManager = locationManager ?? LocationManager()
    }

    /// Loads all providers for the map if not already populated.
    func loadProviders() async {
        guard providers.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            // Fetch first 100 providers so the map has rich pins
            let page = try await providerService.fetchProviders(city: nil, activityId: nil, page: 0, size: 100)
            self.providers = page.content
            adjustCameraToPins()
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }

    /// Allows sharing data from the List screen so we don't refetch everything (prepared for Step 5).
    func setProviders(_ newProviders: [Provider]) {
        self.providers = newProviders
        adjustCameraToPins()
    }

    /// Requests GPS location and animates map camera to user's coordinate.
    func centerOnUser() {
        locationManager.requestLocation()
        if let userCoord = locationManager.userLocation {
            withAnimation(.easeInOut(duration: 0.8)) {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: userCoord,
                        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                    )
                )
            }
        }
    }

    /// Selects a provider pin and centers camera on it.
    func selectProvider(_ provider: Provider) {
        selectedProviderId = provider.id
        if let coord = provider.coordinate {
            withAnimation(.easeInOut(duration: 0.5)) {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                    )
                )
            }
        }
    }

    /// Adjusts the initial camera bounds to fit the pins if available.
    private func adjustCameraToPins() {
        let validCoords = providersWithCoordinates.compactMap { $0.coordinate }
        guard let first = validCoords.first else { return }

        if validCoords.count == 1 {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: first,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            )
        } else {
            cameraPosition = .automatic
        }
    }
}
