//
//  SimplifiedDebtsView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct SimplifiedDebtsView: View {
    let group: SDGroup
    let transactions: [SimplifiedDebtTransaction]
    let currentUserId: String

    @State private var settleFriendSummary: FriendBalanceSummary? = nil

    public init(group: SDGroup, transactions: [SimplifiedDebtTransaction], currentUserId: String) {
        self.group = group
        self.transactions = transactions
        self.currentUserId = currentUserId
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Debt Simplification")
                        .font(.headline)
                    Text("Min-cash-flow algorithm reduced debts to \(transactions.count) transactions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                StatusBadge("Optimized", icon: "bolt.shield.fill", color: .appPrimary)
            }

            if transactions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.owedPositive)
                        Text("All group balances are settled!")
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
                .elevatedCard()
            } else {
                VStack(spacing: 10) {
                    ForEach(transactions) { tx in
                        let involvesMe = tx.fromUserId == currentUserId || tx.toUserId == currentUserId

                        Button(action: {
                            if involvesMe {
                                HapticManager.selection()
                                triggerSettle(for: tx)
                            }
                        }) {
                            HStack(spacing: 12) {
                                UserAvatarView(name: nameForId(tx.fromUserId), size: 36)

                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 4) {
                                        Text(tx.fromUserId == currentUserId ? "You" : nameForId(tx.fromUserId))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.primary)
                                        Text("pays")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                        Text(tx.toUserId == currentUserId ? "You" : nameForId(tx.toUserId))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.primary)
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(tx.amountMinorUnits, currency: group.currency)))")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(tx.fromUserId == currentUserId ? .owedNegative : (tx.toUserId == currentUserId ? .owedPositive : .primary))

                                    if involvesMe {
                                        Text("Tap to Settle")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.appPrimary)
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)

                        if tx.id != transactions.last?.id {
                            Divider()
                        }
                    }
                }
                .elevatedCard()
            }
        }
        .sheet(item: $settleFriendSummary) { friend in
            SettleUpView(friend: friend, groups: [group])
        }
    }

    private func triggerSettle(for tx: SimplifiedDebtTransaction) {
        let otherId = tx.fromUserId == currentUserId ? tx.toUserId : tx.fromUserId
        let otherMember = group.members.first(where: { $0.id == otherId })
        let net = tx.fromUserId == currentUserId ? -tx.amountMinorUnits : tx.amountMinorUnits

        settleFriendSummary = FriendBalanceSummary(
            memberId: otherId,
            name: otherMember?.name ?? "Friend",
            phoneNumber: otherMember?.phoneNumber ?? "",
            isPending: otherMember?.isPending ?? false,
            upiId: otherMember?.upiId,
            netMinorUnits: net,
            currency: group.currency
        )
    }

    private func nameForId(_ id: String) -> String {
        group.members.first(where: { $0.id == id })?.name ?? "Member"
    }
}
