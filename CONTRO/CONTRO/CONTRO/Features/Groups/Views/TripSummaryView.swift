//
//  TripSummaryView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import Charts

public struct TripSummaryView: View {
    let group: SDGroup

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Trip Header Card
                VStack(spacing: 12) {
                    Text(group.emoji)
                        .font(.system(size: 56))

                    Text(group.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))

                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Text("Total Trip Cost")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(totalCostMinorUnits, currency: group.currency)))")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.appPrimary)
                        }

                        VStack(spacing: 4) {
                            Text("Per Person Avg")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(perPersonCostMinorUnits, currency: group.currency)))")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .elevatedCard()

                // Top Expenses
                VStack(alignment: .leading, spacing: 12) {
                    Text("Top Expenses")
                        .font(.headline)

                    ForEach(topExpenses) { exp in
                        HStack(spacing: 12) {
                            Image(systemName: exp.category.systemImage)
                                .font(.system(size: 18))
                                .foregroundColor(exp.category.color)
                                .frame(width: 36, height: 36)
                                .background(exp.category.color.opacity(0.12))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(exp.title)
                                    .font(.subheadline.weight(.semibold))
                                Text(exp.category.displayName)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text("\(exp.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(exp.amountMinorUnits, currency: exp.currency)))")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .elevatedCard(cornerRadius: 12, padding: 12)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private var totalCostMinorUnits: Int64 {
        group.activeExpenses.map(\.amountMinorUnits).reduce(0, +)
    }

    private var perPersonCostMinorUnits: Int64 {
        guard !group.members.isEmpty else { return 0 }
        return totalCostMinorUnits / Int64(group.members.count)
    }

    private var topExpenses: [SDExpense] {
        Array(group.activeExpenses.sorted { $0.amountMinorUnits > $1.amountMinorUnits }.prefix(5))
    }
}
