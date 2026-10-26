//
//  ExpenseDetailView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct ExpenseDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let expense: SDExpense
    let group: SDGroup

    @State private var showingDeleteAlert: Bool = false
    @State private var reactions: [String: Int] = ["👍": 2, "❤️": 1]

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 12) {
                    Image(systemName: expense.category.systemImage)
                        .font(.system(size: 32))
                        .foregroundColor(expense.category.color)
                        .frame(width: 64, height: 64)
                        .background(expense.category.color.opacity(0.15))
                        .clipShape(Circle())

                    Text(expense.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))

                    Text("\(expense.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(expense.amountMinorUnits, currency: expense.currency)))")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        Text(expense.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if expense.isRecurring {
                            StatusBadge("Recurring", icon: "repeat", color: .purple)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .elevatedCard()

                // Paid By Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Paid By")
                        .font(.headline)

                    VStack(spacing: 8) {
                        ForEach(expense.payers) { payer in
                            let payerName = group.members.first(where: { $0.id == payer.memberId })?.name ?? "Member"
                            HStack(spacing: 12) {
                                UserAvatarView(name: payerName, size: 36)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(payerName)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    Text("Paid full share")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text("\(expense.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(payer.amountMinorUnits, currency: expense.currency)))")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.owedPositive)
                            }
                            .padding(.vertical, 4)

                            if payer.id != expense.payers.last?.id {
                                Divider()
                            }
                        }
                    }
                    .elevatedCard()
                }

                // Split Breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Split Breakdown (\(expense.splitType.title))")
                        .font(.headline)

                    VStack(spacing: 8) {
                        ForEach(expense.splits) { split in
                            HStack(spacing: 12) {
                                UserAvatarView(name: split.participantName, size: 36)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(split.participantName)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    if let detail = split.detail {
                                        Text(detail)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()

                                Text("\(expense.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(split.amountMinorUnits, currency: expense.currency)))")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            .padding(.vertical, 4)

                            if split.id != expense.splits.last?.id {
                                Divider()
                            }
                        }
                    }
                    .elevatedCard()
                }

                // Optional Notes
                if !expense.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        Text(expense.notes)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .elevatedCard()
                }

                // Reactions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reactions")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        ForEach(["👍", "❤️", "😂", "🔥", "🙏"], id: \.self) { emoji in
                            Button(action: {
                                HapticManager.impact(.light)
                                reactions[emoji, default: 0] += 1
                            }) {
                                HStack(spacing: 4) {
                                    Text(emoji)
                                    if let count = reactions[emoji], count > 0 {
                                        Text("\(count)")
                                            .font(.caption2.bold())
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.surfaceSecondary)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .elevatedCard()

                // Delete Action
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Expense")
                    }
                    .foregroundColor(.owedNegative)
                    .font(.subheadline.weight(.semibold))
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color.surfaceSecondary.ignoresSafeArea())
        .navigationTitle("Expense Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Expense?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                let currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_default"
                let currentUserName = UserDefaults.standard.string(forKey: "splitease_user_name") ?? "You"
                ExpenseViewModel.deleteExpense(expense, actorId: currentUserId, actorName: currentUserName, modelContext: modelContext)
                dismiss()
            }
        } message: {
            Text("This will remove the expense from all member balances.")
        }
    }
}
