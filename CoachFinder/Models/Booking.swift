import Foundation
import SwiftUI

public struct Booking: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let userId: Int
    public let userName: String
    public let userEmail: String
    public let providerId: Int
    public let providerName: String
    public let providerType: String
    public let providerCity: String
    public let activityId: Int?
    public let activityName: String?
    public let sessionTime: String
    public let durationMinutes: Int
    public let status: String
    public let notes: String?
    public let createdAt: String

    public init(
        id: Int,
        userId: Int,
        userName: String,
        userEmail: String,
        providerId: Int,
        providerName: String,
        providerType: String,
        providerCity: String,
        activityId: Int? = nil,
        activityName: String? = nil,
        sessionTime: String,
        durationMinutes: Int = 60,
        status: String = "CONFIRMED",
        notes: String? = nil,
        createdAt: String = ""
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userEmail = userEmail
        self.providerId = providerId
        self.providerName = providerName
        self.providerType = providerType
        self.providerCity = providerCity
        self.activityId = activityId
        self.activityName = activityName
        self.sessionTime = sessionTime
        self.durationMinutes = durationMinutes
        self.status = status
        self.notes = notes
        self.createdAt = createdAt
    }

    public var parsedDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = formatter.date(from: sessionTime) {
            return d
        }
        let fallback = ISO8601DateFormatter()
        return fallback.date(from: sessionTime)
    }

    public var formattedSessionTime: String {
        guard let date = parsedDate else { return sessionTime }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    public var isUpcoming: Bool {
        guard let date = parsedDate else { return false }
        return date > Date() && status.uppercased() != "CANCELLED"
    }

    public var isCancelled: Bool {
        status.uppercased() == "CANCELLED"
    }
}
