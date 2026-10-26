//
//  Currency.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

public enum Currency: String, CaseIterable, Codable, Identifiable, Sendable {
    case inr = "INR"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case cad = "CAD"
    case aud = "AUD"
    case sgd = "SGD"
    case aed = "AED"
    case jpy = "JPY"

    public var id: String { rawValue }

    public var symbol: String {
        switch self {
        case .inr: return "₹"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .cad: return "CA$"
        case .aud: return "A$"
        case .sgd: return "S$"
        case .aed: return "AED"
        case .jpy: return "¥"
        }
    }

    public var displayName: String {
        switch self {
        case .inr: return "Indian Rupee (₹)"
        case .usd: return "US Dollar ($)"
        case .eur: return "Euro (€)"
        case .gbp: return "British Pound (£)"
        case .cad: return "Canadian Dollar (CA$)"
        case .aud: return "Australian Dollar (A$)"
        case .sgd: return "Singapore Dollar (S$)"
        case .aed: return "UAE Dirham (AED)"
        case .jpy: return "Japanese Yen (¥)"
        }
    }

    /// Number of minor units per major unit. (e.g. 100 paise per rupee, 100 cents per dollar, 1 for Yen)
    public var minorUnitMultiplier: Int64 {
        switch self {
        case .jpy:
            return 1
        default:
            return 100
        }
    }

    public var decimalPlaces: Int {
        switch self {
        case .jpy:
            return 0
        default:
            return 2
        }
    }

    public func format(minorUnits: Int64, includeSymbol: Bool = true) -> String {
        let major = Double(minorUnits) / Double(minorUnitMultiplier)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces

        let formattedNumber = formatter.string(from: NSNumber(value: abs(major))) ?? "\(abs(major))"
        let sign = minorUnits < 0 ? "-" : ""
        let prefix = includeSymbol ? "\(symbol)" : ""
        
        // In INR, ₹ is commonly prefixed: ₹1,200.00
        return "\(sign)\(prefix)\(formattedNumber)"
    }
}
