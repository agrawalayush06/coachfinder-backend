//
//  MinorUnits.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

/// Safe integer arithmetic utilities for currencies in minor units (cents, paise).
public struct MinorUnits {
    /// Convert major unit decimal (e.g. 12.50) to minor units (e.g. 1250) for a given currency.
    public static func fromMajorDouble(_ amount: Double, currency: Currency = .inr) -> Int64 {
        let multiplier = Double(currency.minorUnitMultiplier)
        return Int64((amount * multiplier).rounded())
    }

    /// Convert minor units (e.g. 1250) to major unit double (e.g. 12.50) for a given currency.
    public static func toMajorDouble(_ minorUnits: Int64, currency: Currency = .inr) -> Double {
        return Double(minorUnits) / Double(currency.minorUnitMultiplier)
    }

    /// Formats minor units with currency symbol, e.g. "₹12.50"
    public static func format(_ minorUnits: Int64, currency: Currency = .inr) -> String {
        return currency.symbol + String(format: "%.2f", toMajorDouble(minorUnits, currency: currency))
    }

    /// Formats minor units as a decimal number string, e.g. "12.50"
    public static func formatDouble(_ minorUnits: Int64, currency: Currency = .inr) -> String {
        return String(format: "%.2f", toMajorDouble(minorUnits, currency: currency))
    }

    /// Parse a user string input like "1200.50" or "₹1,200.50" into minor units.
    public static func parse(_ text: String, currency: Currency = .inr) -> Int64? {
        let cleaned = text
            .replacingOccurrences(of: currency.symbol, with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let doubleVal = Double(cleaned) else { return nil }
        return fromMajorDouble(doubleVal, currency: currency)
    }

    /// Distribute an amount evenly across N parts, ensuring the sum of parts exactly equals the total
    /// with zero loss of minor units (penny/paise remainder preservation).
    ///
    /// Example: 100 split 3 ways -> [34, 33, 33]
    public static func distribute(amount: Int64, parts: Int) -> [Int64] {
        guard parts > 0 else { return [] }
        let base = amount / Int64(parts)
        let remainder = Int(amount % Int64(parts))
        
        var result = [Int64](repeating: base, count: parts)
        // Distribute remainder 1 minor unit at a time
        if remainder > 0 {
            for i in 0..<remainder {
                result[i] += 1
            }
        } else if remainder < 0 {
            // For negative amounts
            for i in 0..<abs(remainder) {
                result[i] -= 1
            }
        }
        return result
    }

    /// Distribute an amount proportionally according to weights/ratios, preserving exact total sum.
    /// Uses Hare-Niemeyer / Largest Remainder method for integer apportionment.
    public static func distributeProportionally(amount: Int64, weights: [Double]) -> [Int64] {
        guard !weights.isEmpty else { return [] }
        let totalWeight = weights.reduce(0, +)
        guard totalWeight > 0 else {
            return distribute(amount: amount, parts: weights.count)
        }

        // Calculate theoretical quotas
        var integerShares: [Int64] = []
        var remainders: [(index: Int, remainder: Double)] = []

        var distributedSum: Int64 = 0
        for (index, weight) in weights.enumerated() {
            let exact = (Double(amount) * weight) / totalWeight
            let floored = Int64(floor(exact))
            integerShares.append(floored)
            remainders.append((index: index, remainder: exact - Double(floored)))
            distributedSum += floored
        }

        // Distribute remaining units to highest remainder indices
        var leftover = amount - distributedSum
        remainders.sort { $0.remainder > $1.remainder }

        var idx = 0
        while leftover > 0 && idx < remainders.count {
            let targetIdx = remainders[idx].index
            integerShares[targetIdx] += 1
            leftover -= 1
            idx += 1
        }

        return integerShares
    }
}
