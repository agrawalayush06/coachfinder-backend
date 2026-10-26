//
//  HomeDashboardView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct HomeDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<SDGroup> { !$0.isArchived }, sort: \SDGroup.updatedAt, order: .reverse)
    private var groups: [SDGroup]

    @Query private var allExpenses: [SDExpense]
    @Query private var allSettlements: [SDSettlement]

    @State private var viewModel = HomeViewModel()
    @State private var showingAddExpense: Bool = false
    @State private var showingScanner: Bool = false
    @State private var showingSettlePicker: Bool = false
    @State private var showingNoSettleAlert: Bool = false
    @State private var selectedFriend: FriendBalanceSummary? = nil

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroBalanceCard

                    actionShortcutsRow

                    friendsSection

                    groupsPreviewSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .refreshable {
                HapticManager.impact(.light)
                viewModel.refresh(groups: groups)
                await CloudSyncEngine.shared.syncAll(modelContext: modelContext)
            }
            .background(Color.surfaceSecondary.ignoresSafeArea())
            .navigationTitle("SplitEase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("👋 Hello!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        HapticManager.impact(.medium)
                        showingAddExpense = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.appPrimary)
                    }
                }
            }
            .onAppear {
                viewModel.refresh(groups: groups)
            }
            .onChange(of: groups.count) { _, _ in
                viewModel.refresh(groups: groups)
            }
            .onChange(of: allExpenses.count) { _, _ in
                viewModel.refresh(groups: groups)
            }
            .onChange(of: allSettlements.count) { _, _ in
                viewModel.refresh(groups: groups)
            }
            .onChange(of: showingAddExpense) { _, isShowing in
                if !isShowing { viewModel.refresh(groups: groups) }
            }
            .onChange(of: showingScanner) { _, isShowing in
                if !isShowing { viewModel.refresh(groups: groups) }
            }
            .onChange(of: showingSettlePicker) { _, isShowing in
                if !isShowing { viewModel.refresh(groups: groups) }
            }
            .onChange(of: selectedFriend) { _, friend in
                if friend == nil { viewModel.refresh(groups: groups) }
            }
            .onReceive(NotificationCenter.default.publisher(for: .appDataDidChange)) { _ in
                viewModel.refresh(groups: groups)
            }
            .sheet(isPresented: $showingAddExpense) {
                if let firstGroup = groups.first {
                    AddExpenseView(group: firstGroup)
                } else {
                    CreateGroupView()
                }
            }
            .sheet(isPresented: $showingScanner) {
                if let firstGroup = groups.first {
                    ReceiptScannerView(group: firstGroup) { items, tax, total in
                        showingAddExpense = true
                    }
                } else {
                    CreateGroupView()
                }
            }
            .sheet(isPresented: $showingSettlePicker) {
                settleFriendPickerSheet
            }
            .sheet(item: $selectedFriend) { friend in
                FriendDetailView(friend: friend, groups: groups)
            }
            .alert("All Settled Up!", isPresented: $showingNoSettleAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You do not have any pending debts or balances with your friends right now.")
            }
        }
    }

    // MARK: - Hero Balance Card
    private var heroBalanceCard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(balanceTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(viewModel.currency.symbol)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text(String(format: "%.2f", MinorUnits.toMajorDouble(abs(viewModel.netBalanceMinorUnits), currency: viewModel.currency)))
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                }
                .foregroundColor(balanceColor)
            }

            Divider()
                .background(Color.cardBorder)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.left.circle.fill")
                            .foregroundColor(.owedPositive)
                        Text("You are owed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("\(viewModel.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(viewModel.totalOwedToYouMinorUnits, currency: viewModel.currency)))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.owedPositive)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("You owe")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Image(systemName: "arrow.up.right.circle.fill")
                            .foregroundColor(.owedNegative)
                    }
                    Text("\(viewModel.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(viewModel.totalYouOweMinorUnits, currency: viewModel.currency)))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.owedNegative)
                }
            }
        }
        .elevatedCard()
    }

    private var balanceTitle: String {
        if viewModel.netBalanceMinorUnits > 0 {
            return "Overall, you are owed"
        } else if viewModel.netBalanceMinorUnits < 0 {
            return "Overall, you owe"
        } else {
            return "You are all settled up!"
        }
    }

    private var balanceColor: Color {
        if viewModel.netBalanceMinorUnits > 0 {
            return .owedPositive
        } else if viewModel.netBalanceMinorUnits < 0 {
            return .owedNegative
        } else {
            return .primary
        }
    }

    // MARK: - Action Shortcuts Row
    private var actionShortcutsRow: some View {
        HStack(spacing: 12) {
            shortcutButton(title: "Add Expense", icon: "plus", color: .appPrimary) {
                showingAddExpense = true
            }

            shortcutButton(title: "Scan Receipt", icon: "text.viewfinder", color: .purple) {
                showingScanner = true
            }

            shortcutButton(title: "Settle Up", icon: "qrcode", color: .owedPositive) {
                let unsettled = viewModel.friendSummaries.filter { $0.netMinorUnits != 0 }
                if unsettled.isEmpty {
                    showingNoSettleAlert = true
                } else if unsettled.count == 1 {
                    selectedFriend = unsettled.first
                } else {
                    showingSettlePicker = true
                }
            }
        }
    }

    private var settleFriendPickerSheet: some View {
        NavigationStack {
            List(viewModel.friendSummaries.filter { $0.netMinorUnits != 0 }) { friend in
                Button(action: {
                    showingSettlePicker = false
                    selectedFriend = friend
                }) {
                    HStack(spacing: 12) {
                        UserAvatarView(name: friend.name, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(friend.name)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            Text(friend.netMinorUnits > 0 ? "Owes you" : "You owe")
                                .font(.caption2)
                                .foregroundColor(friend.netMinorUnits > 0 ? .owedPositive : .owedNegative)
                        }
                        Spacer()
                        Text("\(friend.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(abs(friend.netMinorUnits), currency: friend.currency)))")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(friend.netMinorUnits > 0 ? .owedPositive : .owedNegative)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Select Friend to Settle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showingSettlePicker = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func shortcutButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.impact(.medium)
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())

                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleTouchStyle())
    }

    // MARK: - Friends Section
    private var friendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Friends & Balances")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.friendSummaries.count) people")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if viewModel.friendSummaries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("No friends or balances yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .elevatedCard()
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.friendSummaries) { friend in
                        Button(action: {
                            HapticManager.selection()
                            selectedFriend = friend
                        }) {
                            HStack(spacing: 12) {
                                UserAvatarView(name: friend.name, isPending: friend.isPending)

                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text(friend.name)
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)

                                        if friend.isPending {
                                            StatusBadge("Pending", color: .orange)
                                        }
                                    }

                                    if !friend.sharedGroupNames.isEmpty {
                                        Text(friend.sharedGroupNames.joined(separator: " • "))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    if friend.netMinorUnits > 0 {
                                        Text("owes you")
                                            .font(.caption2)
                                            .foregroundColor(.owedPositive)
                                        Text("\(friend.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(friend.netMinorUnits, currency: friend.currency)))")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.owedPositive)
                                    } else if friend.netMinorUnits < 0 {
                                        Text("you owe")
                                            .font(.caption2)
                                            .foregroundColor(.owedNegative)
                                        Text("\(friend.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(abs(friend.netMinorUnits), currency: friend.currency)))")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.owedNegative)
                                    } else {
                                        Text("settled up")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary.opacity(0.5))
                            }
                            .padding(.vertical, 8)
                        }
                        if friend.id != viewModel.friendSummaries.last?.id {
                            Divider()
                        }
                    }
                }
                .elevatedCard()
            }
        }
    }

    // MARK: - Groups Preview Section
    private var groupsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Groups")
                    .font(.headline)
                Spacer()
                Text("\(groups.count) groups")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 8) {
                ForEach(groups.prefix(3)) { group in
                    NavigationLink(destination: GroupDetailView(group: group)) {
                        HStack(spacing: 12) {
                            Text(group.emoji)
                                .font(.system(size: 32))
                                .frame(width: 44, height: 44)
                                .background(Color.surfaceSecondary)
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(group.name)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)

                                Text("\(group.members.count) members • \(group.activeExpenses.count) expenses")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                        .padding(.vertical, 8)
                    }
                    if group.id != groups.prefix(3).last?.id {
                        Divider()
                    }
                }
            }
            .elevatedCard()
        }
    }
}
