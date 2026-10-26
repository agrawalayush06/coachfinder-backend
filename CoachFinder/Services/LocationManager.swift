import Foundation
import CoreLocation
import Observation

/// Service wrapper around CLLocationManager to manage location permissions and coordinates.
/// Marked with `@MainActor` and `@Observable` for clean SwiftUI integration.
@Observable
@MainActor
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let clManager = CLLocationManager()

    var authorizationStatus: CLAuthorizationStatus
    var userLocation: CLLocationCoordinate2D?
    var errorMessage: String?
    var isLocating: Bool = false

    override init() {
        self.authorizationStatus = clManager.authorizationStatus
        super.init()
        clManager.delegate = self
        clManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private var isAuthorized: Bool {
        #if os(iOS)
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
        #else
        return authorizationStatus == .authorizedAlways
        #endif
    }

    /// Requests user authorization or requests the latest GPS location.
    func requestLocation() {
        errorMessage = nil
        isLocating = true

        if authorizationStatus == .notDetermined {
            clManager.requestWhenInUseAuthorization()
        } else if isAuthorized {
            clManager.requestLocation()
        } else {
            isLocating = false
            errorMessage = "Location access was denied. Please enable location permissions in Settings to center on your position."
        }
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if self.isAuthorized {
                self.clManager.requestLocation()
            } else if status == .denied || status == .restricted {
                self.isLocating = false
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.userLocation = location.coordinate
            self.isLocating = false
            self.errorMessage = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isLocating = false
            self.errorMessage = error.localizedDescription
        }
    }
}
