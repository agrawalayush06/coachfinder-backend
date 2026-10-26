//
//  ExpenseViewModel.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

@Observable
public final class ExpenseViewModel {
    // Basic Details
    public var title: String = ""
    public var amountMinorUnits: Int64 = 0
    public var currency: Currency = .inr
    public var category: ExpenseCategory = .foodAndDining
    public var date: Date = Date()
    public var notes: String = ""
    public var isRecurring: Bool = false

    // Payer Details
    public var isMultiplePayers: Bool = false
    public var singlePayerId: String = ""
    public var multiplePayers: [String: Int64] = [:] // memberId -> minorUnits

    // Split Details
    public var splitType: SplitType = .equal
    public var selectedParticipantIds: Set<String> = []

    // Split Type Specific States
    public var exactAmounts: [String: Int64] = [:]       // For .exact
    public var percentages: [String: Double] = [:]       // For .percentage
    public var shares: [String: Int] = [:]              // For .shares
    public var adjustments: [String: Int64] = [:]       // For .adjustment
    public var itemizedList: [ItemizedBillItem] = []    // For .itemized
    public var itemizedTaxMinorUnits: Int64 = 0
    public var itemizedTipMinorUnits: Int64 = 0

    // Validation & Error
    public var errorMessage: String? = nil

    public init() {}

    public func setupForNewExpense(group: SDGroup, currentUserId: String) {
        self.title = ""
        self.amountMinorUnits = 0
        self.currency = group.currency
        self.category = .foodAndDining
        self.date = Date()
        self.notes = ""
        self.isRecurring = false
        self.singlePayerId = currentUserId
        self.isMultiplePayers = false
        self.multiplePayers = [:]
        self.splitType = .equal
        self.selectedParticipantIds = Set(group.members.map { $0.id })

        // Initialize shares to 1
        for m in group.members {
            self.shares[m.id] = 1
            self.exactAmounts[m.id] = 0
            self.percentages[m.id] = group.members.count > 0 ? (100.0 / Double(group.members.count)) : 0.0
            self.adjustments[m.id] = 0
        }
        self.itemizedList = []
    }

    public func onTitleChanged(_ newTitle: String) {
        self.title = newTitle
        let suggested = ExpenseCategory.suggest(from: newTitle)
        if suggested != .general {
            self.category = suggested
        }
    }

    public func calculateSplits(group: SDGroup) throws -> [SplitResult] {
        guard amountMinorUnits > 0 else {
            throw SplitError.nonPositiveTotal
        }

        let participants = group.members
            .filter { selectedParticipantIds.contains($0.id) }
            .map { ParticipantShare(id: $0.id, name: $0.name) }

        guard !participants.isEmpty else {
            throw SplitError.emptyParticipants
        }

        switch splitType {
        case .equal:
            return try SplittingEngine.splitEqually(
                totalMinorUnits: amountMinorUnits,
                participants: participants
            )

        case .exact:
            let filtered = exactAmounts.filter { selectedParticipantIds.contains($0.key) }
            return try SplittingEngine.splitExact(
                totalMinorUnits: amountMinorUnits,
                assignments: filtered
            )

        case .percentage:
            let filtered = percentages.filter { selectedParticipantIds.contains($0.key) }
            return try SplittingEngine.splitByPercentage(
                totalMinorUnits: amountMinorUnits,
                percentages: filtered
            )

        case .shares:
            let filtered = shares.filter { selectedParticipantIds.contains($0.key) }
            return try SplittingEngine.splitByShares(
                totalMinorUnits: amountMinorUnits,
                shares: filtered
            )

        case .itemized:
            return try SplittingEngine.splitItemized(
                items: itemizedList,
                participants: participants,
                taxMinorUnits: itemizedTaxMinorUnits,
                tipMinorUnits: itemizedTipMinorUnits
            )

        case .adjustment:
            let filtered = adjustments.filter { selectedParticipantIds.contains($0.key) }
            return try SplittingEngine.splitByAdjustments(
                totalMinorUnits: amountMinorUnits,
                participants: participants,
                adjustments: filtered
            )
        }
    }

    public func saveExpense(group: SDGroup, currentUserId: String, currentUserName: String, modelContext: ModelContext) -> Bool {
        do {
            let splitResults = try calculateSplits(group: group)

            // Setup Payers
            var payers: [ExpensePayer] = []
            if isMultiplePayers {
                let sumPaid = multiplePayers.values.reduce(0, +)
                guard sumPaid == amountMinorUnits else {
                    errorMessage = "Paid amounts (₹\(MinorUnits.toMajorDouble(sumPaid))) must match total expense (₹\(MinorUnits.toMajorDouble(amountMinorUnits)))."
                    HapticManager.notification(.error)
                    return false
                }
                for (id, amt) in multiplePayers where amt > 0 {
                    payers.append(ExpensePayer(memberId: id, amountMinorUnits: amt))
                }
            } else {
                payers.append(ExpensePayer(memberId: singlePayerId, amountMinorUnits: amountMinorUnits))
            }

            // Create Expense
            let expense = SDExpense(
                groupId: group.id,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                amountMinorUnits: amountMinorUnits,
                currencyCode: currency.rawValue,
                categoryRaw: category.rawValue,
                date: date,
                notes: notes,
                payers: payers,
                splitTypeRaw: splitType.rawValue,
                isRecurring: isRecurring,
                createdByUserId: currentUserId
            )
            expense.group = group
            modelContext.insert(expense)
            if !group.expenses.contains(where: { $0.id == expense.id }) {
                group.expenses.append(expense)
            }

            let memberLookup = Dictionary(uniqueKeysWithValues: group.members.map { ($0.id, $0.name) })
            var splitItems: [SDSplitItem] = []
            for r in splitResults {
                let item = SDSplitItem(
                    participantId: r.participantId,
                    participantName: memberLookup[r.participantId] ?? "Member",
                    amountMinorUnits: r.amountMinorUnits,
                    percentage: r.percentage,
                    detail: r.detail
                )
                item.expense = expense
                modelContext.insert(item)
                splitItems.append(item)
            }
            expense.splits = splitItems

            // Audit Activity Log
            let act = SDActivity(
                groupId: group.id,
                actorId: currentUserId,
                actorName: currentUserName,
                typeRaw: ActivityType.expenseCreated.rawValue,
                targetExpenseId: expense.id,
                targetExpenseTitle: expense.title,
                amountMinorUnits: expense.amountMinorUnits,
                message: "\(currentUserName) added \(expense.title)"
            )
            act.group = group
            modelContext.insert(act)
            group.updatedAt = Date()
            CloudSyncEngine.shared.markPendingChange()

            try? modelContext.save()
            DataRefreshCoordinator.notifyDataChanged()
            HapticManager.notification(.success)
            return true
        } catch {
            errorMessage = error.localizedDescription
            HapticManager.notification(.error)
            return false
        }
    }

    public static func deleteExpense(_ expense: SDExpense, actorId: String, actorName: String, modelContext: ModelContext) {
        expense.isDeleted = true
        expense.deletedAt = Date()

        if let group = expense.group {
            let act = SDActivity(
                groupId: group.id,
                actorId: actorId,
                actorName: actorName,
                typeRaw: ActivityType.expenseDeleted.rawValue,
                targetExpenseId: expense.id,
                targetExpenseTitle: expense.title,
                amountMinorUnits: expense.amountMinorUnits,
                message: "\(actorName) deleted \(expense.title)"
            )
            act.group = group
            modelContext.insert(act)
            group.updatedAt = Date()
            CloudSyncEngine.shared.markPendingChange()
        }

        try? modelContext.save()
        DataRefreshCoordinator.notifyDataChanged()
        HapticManager.notification(.warning)
    }

    public static func restoreExpense(_ expense: SDExpense, modelContext: ModelContext) {
        expense.isDeleted = false
        expense.deletedAt = nil
        expense.group?.updatedAt = Date()
        try? modelContext.save()
        DataRefreshCoordinator.notifyDataChanged()
        HapticManager.notification(.success)
    }
}
