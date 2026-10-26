import Foundation
import CoreLocation

struct Provider: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let userId: Int
    let type: String
    let name: String
    let city: String
    let lat: Double?
    let lng: Double?
    let createdAt: String?
    let updatedAt: String?

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = lat, let lng = lng else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    // Conform to Hashable manually since CLLocationCoordinate2D is not Hashable by default
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Provider, rhs: Provider) -> Bool {
        lhs.id == rhs.id
    }
}
