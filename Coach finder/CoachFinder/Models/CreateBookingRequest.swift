import Foundation

public struct CreateBookingRequest: Codable, Sendable {
    public let providerId: Int
    public let activityId: Int?
    public let sessionTime: String
    public let durationMinutes: Int?
    public let notes: String?

    public init(
        providerId: Int,
        activityId: Int? = nil,
        sessionTime: String,
        durationMinutes: Int? = 60,
        notes: String? = nil
    ) {
        self.providerId = providerId
        self.activityId = activityId
        self.sessionTime = sessionTime
        self.durationMinutes = durationMinutes
        self.notes = notes
    }
}
