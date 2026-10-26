//
//  HomeViewModel.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct FriendBalanceSummary: Identifiable, Hashable {
    public var id: String { memberId }
    public let memberId: String
    public let name: String
    public let phoneNumber: String
    public let isPending: Bool
    public let upiId: String?
    public var netMinorUnits: Int64
    public var sharedGroupNames: [String]
    public var currency: Currency

    public init(
        memberId: String,
        name: String,
        phoneNumber: String,
        isPending: Bool = false,
        upiId: String? = nil,
        netMinorUnits: Int64,
        sharedGroupNames: [String] = [],
        currency: Currency = .inr
    ) {
        self.memberId = memberId
        self.name = name
        self.phoneNumber = phoneNumber
        self.isPending = isPending
        self.upiId = upiId
        self.netMinorUnits = netMinorUnits
        self.sharedGroupNames = sharedGroupNames
        self.currency = currency
    }
}

@Observable
public final class HomeViewModel {
    public var currentUserId: String = ""
    public var netBalanceMinorUnits: Int64 = 0
    public var totalOwedToYouMinorUnits: Int64 = 0
    public var totalYouOweMinorUnits: Int64 = 0
    public var friendSummaries: [FriendBalanceSummary] = []
    public var currency: Currency = .inr

    public init() {
        self.currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_default"
        if let currCode = UserDefaults.standard.string(forKey: "splitease_currency"),
           let c = Currency(rawValue: currCode) {
            self.currency = c
        }
    }

    public func refresh(groups: [SDGroup]) {
        self.currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_default"

        var friendMap: [String: (member: GroupMember, net: Int64, groups: Set<String>)] = [:]
        var overallNet: Int64 = 0
        var totalPositive: Int64 = 0
        var totalNegative: Int64 = 0

        for group in groups where !group.isArchived {
            let members = group.members
            let memberLookup = Dictionary(uniqueKeysWithValues: members.map { ($0.id, $0) })

            // Compute pairwise or net balances for group
            var groupExpenses: [(payers: [String: Int64], splits: [String: Int64])] = []
            for exp in group.activeExpenses {
                var payers: [String: Int64] = [:]
                for p in exp.payers {
                    payers[p.memberId] = p.amountMinorUnits
                }
                var splits: [String: Int64] = [:]
                for s in exp.splits {
                    splits[s.participantId] = s.amountMinorUnits
                }
                groupExpenses.append((payers: payers, splits: splits))
            }

            var settlements: [(from: String, to: String, amount: Int64)] = []
            for stl in group.settlements where stl.status == .confirmed {
                settlements.append((from: stl.payerId, to: stl.receiverId, amount: stl.amountMinorUnits))
            }

            let groupNet = DebtSimplification.computeNetBalances(expenses: groupExpenses, settlements: settlements)

            // Calculate pairwise debt simplification for this group
            let simplified = DebtSimplification.simplify(netBalances: groupNet)

            for tx in simplified {
                if tx.fromUserId == currentUserId {
                    // Current user owes tx.toUserId
                    let otherId = tx.toUserId
                    if let otherMember = memberLookup[otherId] {
                        var entry = friendMap[otherId] ?? (member: otherMember, net: 0, groups: [])
                        entry.net -= tx.amountMinorUnits
                        entry.groups.insert(group.name)
                        friendMap[otherId] = entry
                    }
                } else if tx.toUserId == currentUserId {
                    // tx.fromUserId owes current user
                    let otherId = tx.fromUserId
                    if let otherMember = memberLookup[otherId] {
                        var entry = friendMap[otherId] ?? (member: otherMember, net: 0, groups: [])
                        entry.net += tx.amountMinorUnits
                        entry.groups.insert(group.name)
                        friendMap[otherId] = entry
                    }
                }
            }
        }

        var summaries: [FriendBalanceSummary] = []
        for (id, data) in friendMap where id != currentUserId {
            overallNet += data.net
            if data.net > 0 {
                totalPositive += data.net
            } else if data.net < 0 {
                totalNegative += abs(data.net)
            }

            summaries.append(
                FriendBalanceSummary(
                    memberId: id,
                    name: data.member.name,
                    phoneNumber: data.member.phoneNumber,
                    isPending: data.member.isPending,
                    upiId: data.member.upiId,
                    netMinorUnits: data.net,
                    sharedGroupNames: Array(data.groups).sorted(),
                    currency: currency
                )
            )
        }

        self.netBalanceMinorUnits = overallNet
        self.totalOwedToYouMinorUnits = totalPositive
        self.totalYouOweMinorUnits = totalNegative
        self.friendSummaries = summaries.sorted { abs($0.netMinorUnits) > abs($1.netMinorUnits) }
    }
}
