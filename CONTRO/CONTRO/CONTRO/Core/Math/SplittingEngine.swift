//
//  SplittingEngine.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

public struct ParticipantShare: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public struct SplitResult: Identifiable, Hashable, Sendable {
    public var id: String { participantId }
    public let participantId: String
    public let amountMinorUnits: Int64
    public let percentage: Double
    public let detail: String?

    public init(participantId: String, amountMinorUnits: Int64, percentage: Double = 0.0, detail: String? = nil) {
        self.participantId = participantId
        self.amountMinorUnits = amountMinorUnits
        self.percentage = percentage
        self.detail = detail
    }
}

public struct ItemizedBillItem: Identifiable, Hashable, Sendable {
    public let id: String
    public var name: String
    public var amountMinorUnits: Int64
    public var assignedParticipantIds: Set<String>

    public init(id: String = UUID().uuidString, name: String, amountMinorUnits: Int64, assignedParticipantIds: Set<String> = []) {
        self.id = id
        self.name = name
        self.amountMinorUnits = amountMinorUnits
        self.assignedParticipantIds = assignedParticipantIds
    }
}

public enum SplitError: LocalizedError, Equatable {
    case emptyParticipants
    case nonPositiveTotal
    case exactAmountsMismatch(expected: Int64, actual: Int64)
    case invalidPercentageSum(actual: Double)
    case zeroTotalShares
    case itemUnassigned(String)
    case invalidAdjustmentTotal(adjustmentSum: Int64, total: Int64)

    public var errorDescription: String? {
        switch self {
        case .emptyParticipants:
            return "At least one participant must be selected."
        case .nonPositiveTotal:
            return "Expense total must be greater than zero."
        case .exactAmountsMismatch(let expected, let actual):
            return "The sum of exact amounts (\(actual)) does not equal the total amount (\(expected))."
        case .invalidPercentageSum(let actual):
            return String(format: "Percentages must add up to 100%% (currently %.1f%%).", actual)
        case .zeroTotalShares:
            return "Total shares must be greater than 0."
        case .itemUnassigned(let name):
            return "Item \"\(name)\" has not been assigned to any participant."
        case .invalidAdjustmentTotal(let adjustmentSum, let total):
            return "Total adjustments (\(adjustmentSum)) exceed the expense total (\(total))."
        }
    }
}

public struct SplittingEngine {

    // MARK: - 1. Equal Split
    public static func splitEqually(
        totalMinorUnits: Int64,
        participants: [ParticipantShare]
    ) throws -> [SplitResult] {
        guard !participants.isEmpty else { throw SplitError.emptyParticipants }
        guard totalMinorUnits > 0 else { throw SplitError.nonPositiveTotal }

        let distributed = MinorUnits.distribute(amount: totalMinorUnits, parts: participants.count)
        return participants.enumerated().map { index, participant in
            let amount = distributed[index]
            let pct = (Double(amount) / Double(totalMinorUnits)) * 100.0
            return SplitResult(
                participantId: participant.id,
                amountMinorUnits: amount,
                percentage: pct,
                detail: "1/\(participants.count) share"
            )
        }
    }

    // MARK: - 2. Exact Amounts Split
    public static func splitExact(
        totalMinorUnits: Int64,
        assignments: [String: Int64]
    ) throws -> [SplitResult] {
        guard !assignments.isEmpty else { throw SplitError.emptyParticipants }
        guard totalMinorUnits > 0 else { throw SplitError.nonPositiveTotal }

        let actualSum = assignments.values.reduce(0, +)
        guard actualSum == totalMinorUnits else {
            throw SplitError.exactAmountsMismatch(expected: totalMinorUnits, actual: actualSum)
        }

        return assignments.map { (participantId, amount) in
            let pct = (Double(amount) / Double(totalMinorUnits)) * 100.0
            return SplitResult(
                participantId: participantId,
                amountMinorUnits: amount,
                percentage: pct,
                detail: "Exact amount"
            )
        }.sorted { $0.participantId < $1.participantId }
    }

    // MARK: - 3. Percentages Split
    public static func splitByPercentage(
        totalMinorUnits: Int64,
        percentages: [String: Double]
    ) throws -> [SplitResult] {
        guard !percentages.isEmpty else { throw SplitError.emptyParticipants }
        guard totalMinorUnits > 0 else { throw SplitError.nonPositiveTotal }

        let sumPct = percentages.values.reduce(0, +)
        // Allow a small floating tolerance: 99.9% to 100.1%
        guard abs(sumPct - 100.0) < 0.15 else {
            throw SplitError.invalidPercentageSum(actual: sumPct)
        }

        let sortedKeys = percentages.keys.sorted()
        let weights = sortedKeys.map { percentages[$0] ?? 0.0 }
        let distributed = MinorUnits.distributeProportionally(amount: totalMinorUnits, weights: weights)

        return sortedKeys.enumerated().map { index, participantId in
            let amount = distributed[index]
            let pct = percentages[participantId] ?? 0.0
            return SplitResult(
                participantId: participantId,
                amountMinorUnits: amount,
                percentage: pct,
                detail: String(format: "%.1f%%", pct)
            )
        }
    }

    // MARK: - 4. Shares / Ratio Split
    public static func splitByShares(
        totalMinorUnits: Int64,
        shares: [String: Int]
    ) throws -> [SplitResult] {
        guard !shares.isEmpty else { throw SplitError.emptyParticipants }
        guard totalMinorUnits > 0 else { throw SplitError.nonPositiveTotal }

        let totalShares = shares.values.reduce(0, +)
        guard totalShares > 0 else { throw SplitError.zeroTotalShares }

        let sortedKeys = shares.keys.sorted()
        let weights = sortedKeys.map { Double(shares[$0] ?? 0) }
        let distributed = MinorUnits.distributeProportionally(amount: totalMinorUnits, weights: weights)

        return sortedKeys.enumerated().map { index, participantId in
            let amount = distributed[index]
            let shareCount = shares[participantId] ?? 0
            let pct = (Double(amount) / Double(totalMinorUnits)) * 100.0
            return SplitResult(
                participantId: participantId,
                amountMinorUnits: amount,
                percentage: pct,
                detail: "\(shareCount) / \(totalShares) shares"
            )
        }
    }

    // MARK: - 5. Itemized Split (with proportional tax & tip)
    public static func splitItemized(
        items: [ItemizedBillItem],
        participants: [ParticipantShare],
        taxMinorUnits: Int64 = 0,
        tipMinorUnits: Int64 = 0
    ) throws -> [SplitResult] {
        guard !participants.isEmpty else { throw SplitError.emptyParticipants }

        var perParticipantItemTotal: [String: Int64] = [:]
        for p in participants {
            perParticipantItemTotal[p.id] = 0
        }

        // Split each item equally among its assigned participants
        for item in items {
            guard !item.assignedParticipantIds.isEmpty else {
                throw SplitError.itemUnassigned(item.name)
            }
            let assigned = item.assignedParticipantIds
            let parts = MinorUnits.distribute(amount: item.amountMinorUnits, parts: assigned.count)
            for (idx, participantId) in assigned.sorted().enumerated() {
                perParticipantItemTotal[participantId, default: 0] += parts[idx]
            }
        }

        let itemsSubtotal = perParticipantItemTotal.values.reduce(0, +)
        let totalAdditional = taxMinorUnits + tipMinorUnits

        var finalTotals: [String: Int64] = perParticipantItemTotal

        if totalAdditional > 0 && itemsSubtotal > 0 {
            // Allocate tax and tip proportionally to food/item consumption
            let sortedKeys = participants.map { $0.id }
            let weights = sortedKeys.map { Double(perParticipantItemTotal[$0] ?? 0) }
            let additionalDistributed = MinorUnits.distributeProportionally(amount: totalAdditional, weights: weights)

            for (index, participantId) in sortedKeys.enumerated() {
                finalTotals[participantId, default: 0] += additionalDistributed[index]
            }
        } else if totalAdditional > 0 {
            // If items subtotal is 0 (or no items), split tax/tip equally
            let parts = MinorUnits.distribute(amount: totalAdditional, parts: participants.count)
            for (index, p) in participants.enumerated() {
                finalTotals[p.id, default: 0] += parts[index]
            }
        }

        let grandTotal = finalTotals.values.reduce(0, +)

        return participants.map { p in
            let amount = finalTotals[p.id] ?? 0
            let pct = grandTotal > 0 ? (Double(amount) / Double(grandTotal)) * 100.0 : 0.0
            return SplitResult(
                participantId: p.id,
                amountMinorUnits: amount,
                percentage: pct,
                detail: "Itemized total"
            )
        }
    }

    // MARK: - 6. Adjustments Split
    /// Splits base amount equally, then applies fixed adjustments (e.g. +100 to person A, -100 to person B)
    public static func splitByAdjustments(
        totalMinorUnits: Int64,
        participants: [ParticipantShare],
        adjustments: [String: Int64]
    ) throws -> [SplitResult] {
        guard !participants.isEmpty else { throw SplitError.emptyParticipants }
        guard totalMinorUnits > 0 else { throw SplitError.nonPositiveTotal }

        let netAdjustmentSum = adjustments.values.reduce(0, +)
        guard netAdjustmentSum < totalMinorUnits else {
            throw SplitError.invalidAdjustmentTotal(adjustmentSum: netAdjustmentSum, total: totalMinorUnits)
        }

        // Remaining amount to split equally
        let remainingToSplit = totalMinorUnits - netAdjustmentSum
        let baseSplits = MinorUnits.distribute(amount: remainingToSplit, parts: participants.count)

        return participants.enumerated().map { index, participant in
            let adj = adjustments[participant.id] ?? 0
            let amount = baseSplits[index] + adj
            let pct = (Double(amount) / Double(totalMinorUnits)) * 100.0
            let sign = adj >= 0 ? "+\(adj)" : "\(adj)"
            return SplitResult(
                participantId: participant.id,
                amountMinorUnits: amount,
                percentage: pct,
                detail: adj != 0 ? "Equal split \(sign) adjustment" : "Equal split"
            )
        }
    }
}
