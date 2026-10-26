//
//  InsightsDashboardView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import Charts
import SwiftData

public struct CategorySpendItem: Identifiable {
    public var id: String { category.rawValue }
    public let category: ExpenseCategory
    public let amountMinorUnits: Int64
    public let percentage: Double
}

public struct InsightsDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<SDGroup> { !$0.isArchived }) private var groups: [SDGroup]

    @State private var selectedTimeRange: Int = 0 // 0: This Month, 1: All Time
    @State private var selectedCategory: ExpenseCategory? = nil
    @State private var refreshId = UUID()

    private var userCurrency: Currency {
        if let code = UserDefaults.standard.string(forKey: "splitease_currency"),
           let c = Currency(rawValue: code) {
            return c
        }
        return .inr
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Time range selector
                    Picker("Time Range", selection: $selectedTimeRange) {
                        Text("This Month").tag(0)
                        Text("All Time").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)

                    // Smart Insight Hero Banner
                    smartInsightCard

                    // Category Donut Chart
                    categoryDonutChartCard

                    // Monthly Spending Trend
                    spendingBarChartCard

                    // Per-Group Contributions
                    groupContributionCard
                }
                .padding(.vertical, 12)
            }
            .id(refreshId)
            .refreshable {
                HapticManager.impact(.light)
                refreshId = UUID()
                await CloudSyncEngine.shared.syncAll(modelContext: modelContext)
            }
            .background(Color.surfaceSecondary.ignoresSafeArea())
            .navigationTitle("Insights")
            .onReceive(NotificationCenter.default.publisher(for: .appDataDidChange)) { _ in
                refreshId = UUID()
            }
        }
    }

    // MARK: - Smart AI Insight Card
    private var smartInsightCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "lightbulb.max.fill")
                .font(.system(size: 28))
                .foregroundColor(.orange)
                .frame(width: 48, height: 48)
                .background(Color.orange.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Smart Spending Insight")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)

                if let top = categoryBreakdown.first {
                    Text("Your highest expenditure is \(top.category.displayName) (\(String(format: "%.0f%%", top.percentage))), totaling \(userCurrency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(top.amountMinorUnits, currency: userCurrency))).")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                } else {
                    Text("Track more group expenses to unlock personalized financial insights.")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
            }
        }
        .padding(.horizontal, 16)
        .elevatedCard()
        .padding(.horizontal, 16)
    }

    // MARK: - Category Donut Chart
    private var categoryDonutChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.headline)

            if categoryBreakdown.isEmpty {
                Text("No categorized expenses yet.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Chart(categoryBreakdown) { item in
                    SectorMark(
                        angle: .value("Amount", item.amountMinorUnits),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(item.category.color)
                    .cornerRadius(5)
                }
                .frame(height: 220)

                // Legend
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(categoryBreakdown) { item in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(item.category.color)
                                .frame(width: 10, height: 10)

                            Text(item.category.displayName)
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)

                            Spacer()

                            Text(String(format: "%.0f%%", item.percentage))
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .elevatedCard()
        .padding(.horizontal, 16)
    }

    // MARK: - Spending Trend Card
    private var spendingBarChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Expense Categories")
                .font(.headline)

            Chart(categoryBreakdown.prefix(4)) { item in
                BarMark(
                    x: .value("Category", item.category.displayName),
                    y: .value("Amount", MinorUnits.toMajorDouble(item.amountMinorUnits, currency: userCurrency))
                )
                .foregroundStyle(item.category.color.gradient)
                .cornerRadius(6)
            }
            .frame(height: 180)
        }
        .padding(.horizontal, 16)
        .elevatedCard()
        .padding(.horizontal, 16)
    }

    // MARK: - Group Contribution Card
    private var groupContributionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Group")
                .font(.headline)

            ForEach(groups) { g in
                let total = g.activeExpenses.map(\.amountMinorUnits).reduce(0, +)
                HStack(spacing: 12) {
                    Text(g.emoji)
                        .font(.title2)
                    Text(g.name)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                    Spacer()
                    Text("\(g.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(total, currency: g.currency)))")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .padding(.vertical, 4)
            }
        }
        .padding(.horizontal, 16)
        .elevatedCard()
        .padding(.horizontal, 16)
    }

    private var filteredExpenses: [SDExpense] {
        let all = groups.flatMap { $0.activeExpenses }
        if selectedTimeRange == 0 {
            let calendar = Calendar.current
            let now = Date()
            return all.filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .month) &&
                calendar.isDate($0.date, equalTo: now, toGranularity: .year)
            }
        } else {
            return all
        }
    }

    private var categoryBreakdown: [CategorySpendItem] {
        var map: [ExpenseCategory: Int64] = [:]
        for e in filteredExpenses {
            map[e.category, default: 0] += e.amountMinorUnits
        }

        let total = map.values.reduce(0, +)
        guard total > 0 else { return [] }

        return map.map { (cat, amount) in
            let pct = (Double(amount) / Double(total)) * 100.0
            return CategorySpendItem(category: cat, amountMinorUnits: amount, percentage: pct)
        }.sorted { $0.amountMinorUnits > $1.amountMinorUnits }
    }
}
