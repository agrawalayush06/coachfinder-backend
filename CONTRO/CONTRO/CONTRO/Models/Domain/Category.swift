//
//  Category.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public enum ExpenseCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case foodAndDining = "food_and_dining"
    case accommodation = "accommodation"
    case transportation = "transportation"
    case groceries = "groceries"
    case entertainment = "entertainment"
    case shopping = "shopping"
    case utilities = "utilities"
    case flights = "flights"
    case medical = "medical"
    case general = "general"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .foodAndDining: return "Food & Dining"
        case .accommodation: return "Accommodation"
        case .transportation: return "Transportation"
        case .groceries: return "Groceries"
        case .entertainment: return "Entertainment"
        case .shopping: return "Shopping"
        case .utilities: return "Utilities"
        case .flights: return "Flights"
        case .medical: return "Medical & Health"
        case .general: return "General"
        }
    }

    public var systemImage: String {
        switch self {
        case .foodAndDining: return "fork.knife"
        case .accommodation: return "bed.double.fill"
        case .transportation: return "car.fill"
        case .groceries: return "cart.fill"
        case .entertainment: return "ticket.fill"
        case .shopping: return "bag.fill"
        case .utilities: return "bolt.fill"
        case .flights: return "airplane"
        case .medical: return "cross.case.fill"
        case .general: return "tag.fill"
        }
    }

    public var color: Color {
        switch self {
        case .foodAndDining: return .orange
        case .accommodation: return .indigo
        case .transportation: return .blue
        case .groceries: return .green
        case .entertainment: return .purple
        case .shopping: return .pink
        case .utilities: return .yellow
        case .flights: return .teal
        case .medical: return .red
        case .general: return .gray
        }
    }

    /// Smart Auto-Classification: Guess category based on expense title keywords.
    public static func suggest(from title: String) -> ExpenseCategory {
        let lower = title.lowercased()
        if lower.contains("flight") || lower.contains("indigo") || lower.contains("air india") || lower.contains("ticket") {
            return .flights
        } else if lower.contains("hotel") || lower.contains("airbnb") || lower.contains("villa") || lower.contains("stay") || lower.contains("resort") {
            return .accommodation
        } else if lower.contains("uber") || lower.contains("ola") || lower.contains("cab") || lower.contains("taxi") || lower.contains("petrol") || lower.contains("fuel") || lower.contains("toll") {
            return .transportation
        } else if lower.contains("dinner") || lower.contains("lunch") || lower.contains("breakfast") || lower.contains("cafe") || lower.contains("coffee") || lower.contains("starbucks") || lower.contains("zomato") || lower.contains("swiggy") || lower.contains("burger") || lower.contains("pizza") || lower.contains("restaurant") || lower.contains("beer") || lower.contains("bar") {
            return .foodAndDining
        } else if lower.contains("grocer") || lower.contains("blinkit") || lower.contains("zepto") || lower.contains("instamart") || lower.contains("milk") || lower.contains("vegetable") || lower.contains("fruit") || lower.contains("supermarket") {
            return .groceries
        } else if lower.contains("movie") || lower.contains("cinema") || lower.contains("game") || lower.contains("club") || lower.contains("concert") || lower.contains("party") {
            return .entertainment
        } else if lower.contains("wifi") || lower.contains("internet") || lower.contains("electricity") || lower.contains("water") || lower.contains("gas") || lower.contains("recharge") || lower.contains("maid") || lower.contains("cook") {
            return .utilities
        } else if lower.contains("mall") || lower.contains("amazon") || lower.contains("flipkart") || lower.contains("clothes") || lower.contains("zara") || lower.contains("h&m") {
            return .shopping
        } else if lower.contains("pharmacy") || lower.contains("medicine") || lower.contains("hospital") || lower.contains("doctor") || lower.contains("apollo") {
            return .medical
        }
        return .general
    }
}
