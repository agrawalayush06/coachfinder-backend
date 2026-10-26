//
//  DebtSimplification.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

public struct SimplifiedDebtTransaction: Identifiable, Hashable, Sendable {
    public let id: String
    public let fromUserId: String
    public let toUserId: String
    public let amountMinorUnits: Int64

    public init(id: String = UUID().uuidString, fromUserId: String, toUserId: String, amountMinorUnits: Int64) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.amountMinorUnits = amountMinorUnits
    }
}

public struct RawPairwiseDebt: Hashable, Sendable {
    public let debtorId: String
    public let creditorId: String
    public let amountMinorUnits: Int64

    public init(debtorId: String, creditorId: String, amountMinorUnits: Int64) {
        self.debtorId = debtorId
        self.creditorId = creditorId
        self.amountMinorUnits = amountMinorUnits
    }
}

/// Greedy bipartite transaction minimization algorithm.
/// Reduces O(N^2) pairwise debts to at most N - 1 settlement transactions.
public struct DebtSimplification {

    /// Compute simplified settlement transactions from net balances.
    /// - Parameter netBalances: Dictionary mapping userId -> net balance in minor units.
    ///   Positive means they are owed money (creditor).
    ///   Negative means they owe money (debtor).
    /// - Returns: Minimal list of direct settlement transactions (debtor -> creditor).
    public static func simplify(netBalances: [String: Int64]) -> [SimplifiedDebtTransaction] {
        // Step 1: Filter out anyone with net balance == 0
        var creditors: [(id: String, amount: Int64)] = []
        var debtors: [(id: String, amount: Int64)] = []

        for (userId, net) in netBalances {
            if net > 0 {
                creditors.append((id: userId, amount: net))
            } else if net < 0 {
                debtors.append((id: userId, amount: -net)) // Store positive debt amount
            }
        }

        var transactions: [SimplifiedDebtTransaction] = []

        // Step 2: Sort descending by magnitude to prioritize settling largest debts first
        creditors.sort { $0.amount > $1.amount }
        debtors.sort { $0.amount > $1.amount }

        var cIdx = 0
        var dIdx = 0

        while cIdx < creditors.count && dIdx < debtors.count {
            let credit = creditors[cIdx].amount
            let debt = debtors[dIdx].amount
            let settleAmount = min(credit, debt)

            if settleAmount > 0 {
                transactions.append(
                    SimplifiedDebtTransaction(
                        fromUserId: debtors[dIdx].id,
                        toUserId: creditors[cIdx].id,
                        amountMinorUnits: settleAmount
                    )
                )
            }

            creditors[cIdx].amount -= settleAmount
            debtors[dIdx].amount -= settleAmount

            if creditors[cIdx].amount == 0 {
                cIdx += 1
            }
            if debtors[dIdx].amount == 0 {
                dIdx += 1
            }
        }

        return transactions
    }

    /// Compute net balances from a list of pairwise raw debts, then simplify.
    public static func simplifyPairwise(debts: [RawPairwiseDebt]) -> [SimplifiedDebtTransaction] {
        var netBalances: [String: Int64] = [:]

        for debt in debts {
            guard debt.amountMinorUnits > 0, debt.debtorId != debt.creditorId else { continue }
            // Debtor owes money -> decrease net balance
            netBalances[debt.debtorId, default: 0] -= debt.amountMinorUnits
            // Creditor is owed money -> increase net balance
            netBalances[debt.creditorId, default: 0] += debt.amountMinorUnits
        }

        return simplify(netBalances: netBalances)
    }

    /// Calculate net balances for participants given a list of expenses and settlements.
    /// Each expense has payers (who paid what) and splits (who owed what).
    public static func computeNetBalances(
        expenses: [(payers: [String: Int64], splits: [String: Int64])],
        settlements: [(from: String, to: String, amount: Int64)] = []
    ) -> [String: Int64] {
        var net: [String: Int64] = [:]

        for exp in expenses {
            for (payerId, paidAmount) in exp.payers {
                net[payerId, default: 0] += paidAmount
            }
            for (splitId, oweAmount) in exp.splits {
                net[splitId, default: 0] -= oweAmount
            }
        }

        for stl in settlements {
            // Settle-up: `from` paid `to`.
            // So `from` balance increases (debt reduced), `to` balance decreases (credit reduced).
            net[stl.from, default: 0] += stl.amount
            net[stl.to, default: 0] -= stl.amount
        }

        return net
    }
}
