import Foundation
import CoreLocation

public struct Provider: Codable, Identifiable, Equatable, Hashable, Sendable {
    public let id: Int
    public let userId: Int
    public let type: String
    public let name: String
    public let city: String
    public let lat: Double?
    public let lng: Double?
    public let distanceKm: Double?
    public let createdAt: String?
    public let updatedAt: String?

    public init(
        id: Int,
        userId: Int,
        type: String,
        name: String,
        city: String,
        lat: Double? = nil,
        lng: Double? = nil,
        distanceKm: Double? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.name = name
        self.city = city
        self.lat = lat
        self.lng = lng
        self.distanceKm = distanceKm
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var coordinate: CLLocationCoordinate2D? {
        guard let lat = lat, let lng = lng else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    public var formattedDistance: String? {
        guard let distanceKm = distanceKm else { return nil }
        if distanceKm < 1.0 {
            return String(format: "%.0f m away", distanceKm * 1000)
        } else {
            return String(format: "%.1f km away", distanceKm)
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Provider, rhs: Provider) -> Bool {
        lhs.id == rhs.id
    }
}
