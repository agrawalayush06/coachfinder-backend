//
//  FriendDetailView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct FriendDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let friend: FriendBalanceSummary
    let groups: [SDGroup]

    @State private var showingSettleUpSheet: Bool = false

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 12) {
                        UserAvatarView(name: friend.name, size: 80, isPending: friend.isPending)

                        VStack(spacing: 4) {
                            Text(friend.name)
                                .font(.system(size: 22, weight: .bold, design: .rounded))

                            Text(friend.phoneNumber)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if let upi = friend.upiId {
                                StatusBadge("UPI: \(upi)", icon: "qrcode", color: .appPrimary)
                                    .padding(.top, 4)
                            }
                        }

                        // Net Balance with friend
                        HStack(spacing: 6) {
                            if friend.netMinorUnits > 0 {
                                Text("\(friend.name) owes you")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(friend.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(friend.netMinorUnits, currency: friend.currency)))")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundColor(.owedPositive)
                            } else if friend.netMinorUnits < 0 {
                                Text("You owe \(friend.name)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(friend.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(abs(friend.netMinorUnits), currency: friend.currency)))")
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundColor(.owedNegative)
                            } else {
                                Text("You are all settled up with \(friend.name)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 8)

                        if friend.netMinorUnits != 0 {
                            PrimaryButton("Settle Up with \(friend.name)", icon: "checkmark.circle.fill", variant: .primary) {
                                showingSettleUpSheet = true
                            }
                            .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .elevatedCard()

                    // Shared Groups
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Shared Groups")
                            .font(.headline)

                        ForEach(sharedGroupsList) { group in
                            HStack(spacing: 12) {
                                Text(group.emoji)
                                    .font(.title2)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(group.name)
                                        .font(.subheadline.weight(.semibold))
                                    Text("\(group.activeExpenses.count) shared expenses")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .elevatedCard(cornerRadius: 12, padding: 12)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color.surfaceSecondary.ignoresSafeArea())
            .navigationTitle(friend.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showingSettleUpSheet) {
                SettleUpView(friend: friend, groups: sharedGroupsList)
            }
            .onReceive(NotificationCenter.default.publisher(for: .appDataDidChange)) { _ in
                dismiss()
            }
        }
    }

    private var sharedGroupsList: [SDGroup] {
        groups.filter { g in
            g.members.contains(where: { $0.id == friend.memberId })
        }
    }
}
