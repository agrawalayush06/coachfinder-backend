//
//  GroupDetailView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct PDFTransferable: Transferable {
    let data: Data
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { file in
            file.data
        }
    }
}

public struct GroupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var group: SDGroup

    @State private var viewModel = GroupViewModel()
    @State private var selectedTab: Int = 0
    @State private var showingAddExpense: Bool = false
    @State private var showingSettings: Bool = false
    @State private var showingAddMemberSheet: Bool = false
    @State private var newMemberName: String = ""
    @State private var newMemberPhone: String = ""
    @State private var refreshId = UUID()

    public init(group: SDGroup) {
        self.group = group
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Segmented Header
            Picker("Group View", selection: $selectedTab) {
                Text("Expenses").tag(0)
                Text("Debts").tag(1)
                Text("Summary").tag(2)
                Text("Members").tag(3)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            // Direct View Switcher without ScrollView gesture conflicts
            Group {
                switch selectedTab {
                case 0: expensesTabView
                case 1: debtsTabView
                case 2: TripSummaryView(group: group)
                case 3: membersTabView
                default: EmptyView()
                }
            }
            .id(refreshId)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.surfaceSecondary.ignoresSafeArea())
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Menu {
                        ShareLink(item: CSVExporter.generateCSV(group: group), subject: Text("\(group.name) - CSV Export")) {
                            Label("Export CSV", systemImage: "tablecells")
                        }

                        ShareLink(
                            item: PDFTransferable(data: PDFExporter.generateGroupReport(group: group)),
                            preview: SharePreview("\(group.name) Report", image: Image(systemName: "doc.text.fill"))
                        ) {
                            Label("Export PDF Summary", systemImage: "doc.text")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }

                    Button(action: {
                        HapticManager.impact(.medium)
                        showingAddExpense = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.appPrimary)
                    }
                }
            }
        }
        .onAppear {
            viewModel.calculateGroupDetails(group: group)
        }
        .onChange(of: group.updatedAt) { _, _ in
            viewModel.calculateGroupDetails(group: group)
            refreshId = UUID()
        }
        .onChange(of: group.expenses.count) { _, _ in
            viewModel.calculateGroupDetails(group: group)
            refreshId = UUID()
        }
        .onChange(of: group.settlements.count) { _, _ in
            viewModel.calculateGroupDetails(group: group)
            refreshId = UUID()
        }
        .onChange(of: showingAddExpense) { _, isShowing in
            if !isShowing {
                viewModel.calculateGroupDetails(group: group)
                refreshId = UUID()
            }
        }
        .onChange(of: showingSettings) { _, isShowing in
            if !isShowing {
                viewModel.calculateGroupDetails(group: group)
                refreshId = UUID()
            }
        }
        .onChange(of: showingAddMemberSheet) { _, isShowing in
            if !isShowing {
                viewModel.calculateGroupDetails(group: group)
                refreshId = UUID()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .appDataDidChange)) { _ in
            viewModel.calculateGroupDetails(group: group)
            refreshId = UUID()
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(group: group)
        }
        .sheet(isPresented: $showingSettings) {
            GroupSettingsView(group: group)
        }
        .sheet(isPresented: $showingAddMemberSheet) {
            addMemberSheet
        }
    }

    // MARK: - Expenses Tab
    private var expensesTabView: some View {
        ScrollView {
            VStack(spacing: 16) {
                groupHeroCard

                if group.activeExpenses.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text("No expenses in this group yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        PrimaryButton("Add First Expense", icon: "plus") {
                            showingAddExpense = true
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .elevatedCard()
                } else {
                    VStack(spacing: 8) {
                        ForEach(group.activeExpenses) { expense in
                            NavigationLink(destination: ExpenseDetailView(expense: expense, group: group)) {
                                expenseRow(expense: expense)
                            }

                            if expense.id != group.activeExpenses.last?.id {
                                Divider()
                            }
                        }
                    }
                    .elevatedCard()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .refreshable {
            HapticManager.impact(.light)
            viewModel.calculateGroupDetails(group: group)
            refreshId = UUID()
        }
    }

    private var groupHeroCard: some View {
        HStack(spacing: 16) {
            Text(group.emoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(Color.surfaceCard)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                Text("\(group.members.count) members • \(group.category.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Total Spend")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(viewModel.totalGroupSpendMinorUnits, currency: group.currency)))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.appPrimary)
            }
        }
        .elevatedCard()
    }

    private func expenseRow(expense: SDExpense) -> some View {
        HStack(spacing: 12) {
            Image(systemName: expense.category.systemImage)
                .font(.system(size: 20))
                .foregroundColor(expense.category.color)
                .frame(width: 44, height: 44)
                .background(expense.category.color.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Text(payerSummaryText(for: expense))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(expense.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(expense.amountMinorUnits, currency: expense.currency)))")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                if let mySplit = expense.splits.first(where: { $0.participantId == viewModel.currentUserId }) {
                    Text("your share: \(expense.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(mySplit.amountMinorUnits, currency: expense.currency)))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(.vertical, 6)
    }

    private func payerSummaryText(for expense: SDExpense) -> String {
        let payers = expense.payers
        if payers.count == 1, let single = payers.first {
            let name = group.members.first(where: { $0.id == single.memberId })?.name ?? "Someone"
            return "\(name == UserDefaults.standard.string(forKey: "splitease_user_name") ? "You" : name) paid"
        } else {
            return "\(payers.count) people paid"
        }
    }

    // MARK: - Debts Tab
    private var debtsTabView: some View {
        ScrollView {
            VStack(spacing: 16) {
                SimplifiedDebtsView(
                    group: group,
                    transactions: viewModel.simplifiedDebts,
                    currentUserId: viewModel.currentUserId
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .refreshable {
            HapticManager.impact(.light)
            viewModel.calculateGroupDetails(group: group)
            refreshId = UUID()
        }
    }

    // MARK: - Members Tab
    private var membersTabView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Group Members (\(group.members.count))")
                        .font(.headline)
                    Spacer()
                    Button(action: { showingAddMemberSheet = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.badge.plus")
                            Text("Add Member")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.appPrimary)
                    }
                }

                VStack(spacing: 8) {
                    ForEach(viewModel.memberBalances) { b in
                        HStack(spacing: 12) {
                            UserAvatarView(name: b.member.name, isPending: b.member.isPending)

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(b.member.name)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    if b.member.isPending {
                                        StatusBadge("Pending", color: .orange)
                                    }
                                }
                                Text("Paid: \(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(b.totalPaidMinorUnits, currency: group.currency)))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                if b.netBalanceMinorUnits > 0 {
                                    Text("gets back")
                                        .font(.caption2)
                                        .foregroundColor(.owedPositive)
                                    Text("\(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(b.netBalanceMinorUnits, currency: group.currency)))")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.owedPositive)
                                } else if b.netBalanceMinorUnits < 0 {
                                    Text("owes")
                                        .font(.caption2)
                                        .foregroundColor(.owedNegative)
                                    Text("\(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(abs(b.netBalanceMinorUnits), currency: group.currency)))")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.owedNegative)
                                } else {
                                    Text("settled")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 6)

                        if b.id != viewModel.memberBalances.last?.id {
                            Divider()
                        }
                    }
                }
                .elevatedCard()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .refreshable {
            HapticManager.impact(.light)
            viewModel.calculateGroupDetails(group: group)
            refreshId = UUID()
        }
    }

    private var addMemberSheet: some View {
        NavigationStack {
            Form {
                Section("Friend Details") {
                    TextField("Full Name", text: $newMemberName)
                    TextField("Mobile Number (+91...)", text: $newMemberPhone)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("Add Pending Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newMemberName = ""
                        newMemberPhone = ""
                        showingAddMemberSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addPendingMember(to: group, name: newMemberName, phoneNumber: newMemberPhone, modelContext: modelContext)
                        newMemberName = ""
                        newMemberPhone = ""
                        showingAddMemberSheet = false
                    }
                    .disabled(newMemberName.isEmpty || newMemberPhone.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
