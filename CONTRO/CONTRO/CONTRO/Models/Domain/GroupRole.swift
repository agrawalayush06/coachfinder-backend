//
//  GroupRole.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

public enum GroupRole: String, CaseIterable, Codable, Sendable {
    case admin = "admin"
    case member = "member"

    public var title: String {
        switch self {
        case .admin: return "Admin"
        case .member: return "Member"
        }
    }
}

public enum GroupCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case trip = "trip"
    case flatmates = "flatmates"
    case couple = "couple"
    case event = "event"
    case project = "project"
    case other = "other"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .trip: return "Trip / Vacation"
        case .flatmates: return "Flatmates / Apartment"
        case .couple: return "Couple / Relationship"
        case .event: return "Event / Party"
        case .project: return "Work / Project"
        case .other: return "Other"
        }
    }

    public var defaultEmoji: String {
        switch self {
        case .trip: return "✈️"
        case .flatmates: return "🏠"
        case .couple: return "❤️"
        case .event: return "🎉"
        case .project: return "💼"
        case .other: return "👥"
        }
    }
}
