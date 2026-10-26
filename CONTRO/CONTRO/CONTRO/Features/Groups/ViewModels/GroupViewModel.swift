//
//  GroupViewModel.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct MemberBalanceDetail: Identifiable, Hashable {
    public var id: String { member.id }
    public let member: GroupMember
    public var totalPaidMinorUnits: Int64
    public var totalOwedMinorUnits: Int64
    public var netBalanceMinorUnits: Int64

    public init(member: GroupMember, totalPaidMinorUnits: Int64, totalOwedMinorUnits: Int64, netBalanceMinorUnits: Int64) {
        self.member = member
        self.totalPaidMinorUnits = totalPaidMinorUnits
        self.totalOwedMinorUnits = totalOwedMinorUnits
        self.netBalanceMinorUnits = netBalanceMinorUnits
    }
}

@Observable
public final class GroupViewModel {
    public var currentUserId: String = ""
    public var memberBalances: [MemberBalanceDetail] = []
    public var simplifiedDebts: [SimplifiedDebtTransaction] = []
    public var totalGroupSpendMinorUnits: Int64 = 0

    public init() {
        self.currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_default"
    }

    public func calculateGroupDetails(group: SDGroup) {
        self.currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_default"

        let members = group.members
        var paidMap: [String: Int64] = [:]
        var oweMap: [String: Int64] = [:]
        var totalSpend: Int64 = 0

        var expensesData: [(payers: [String: Int64], splits: [String: Int64])] = []

        for exp in group.activeExpenses {
            totalSpend += exp.amountMinorUnits

            var payers: [String: Int64] = [:]
            for p in exp.payers {
                payers[p.memberId] = p.amountMinorUnits
                paidMap[p.memberId, default: 0] += p.amountMinorUnits
            }

            var splits: [String: Int64] = [:]
            for s in exp.splits {
                splits[s.participantId] = s.amountMinorUnits
                oweMap[s.participantId, default: 0] += s.amountMinorUnits
            }

            expensesData.append((payers: payers, splits: splits))
        }

        var settlementsData: [(from: String, to: String, amount: Int64)] = []
        for stl in group.settlements where stl.status == .confirmed {
            settlementsData.append((from: stl.payerId, to: stl.receiverId, amount: stl.amountMinorUnits))
        }

        let netBalances = DebtSimplification.computeNetBalances(expenses: expensesData, settlements: settlementsData)

        var details: [MemberBalanceDetail] = []
        for m in members {
            let paid = paidMap[m.id] ?? 0
            let owed = oweMap[m.id] ?? 0
            let net = netBalances[m.id] ?? 0
            details.append(MemberBalanceDetail(member: m, totalPaidMinorUnits: paid, totalOwedMinorUnits: owed, netBalanceMinorUnits: net))
        }

        self.totalGroupSpendMinorUnits = totalSpend
        self.memberBalances = details.sorted { $0.netBalanceMinorUnits > $1.netBalanceMinorUnits }
        self.simplifiedDebts = DebtSimplification.simplify(netBalances: netBalances)
    }

    public func addPendingMember(to group: SDGroup, name: String, phoneNumber: String, modelContext: ModelContext) {
        let cleanPhone = phoneNumber.filter { $0.isNumber || $0 == "+" }
        let newMember = GroupMember(
            id: "pending_\(cleanPhone)",
            name: name,
            phoneNumber: cleanPhone,
            role: "member",
            isPending: true
        )

        var currentMembers = group.members
        if !currentMembers.contains(where: { $0.phoneNumber == cleanPhone }) {
            currentMembers.append(newMember)
            group.members = currentMembers
            group.updatedAt = Date()
            try? modelContext.save()
            calculateGroupDetails(group: group)
            DataRefreshCoordinator.notifyDataChanged()
            HapticManager.notification(.success)
        }
    }
}
