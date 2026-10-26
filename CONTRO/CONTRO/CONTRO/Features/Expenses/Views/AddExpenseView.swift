//
//  AddExpenseView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<SDGroup> { !$0.isArchived }, sort: \SDGroup.name) private var allGroups: [SDGroup]

    let initialGroup: SDGroup

    @State private var selectedGroup: SDGroup
    @State private var viewModel = ExpenseViewModel()
    @State private var showingErrorAlert: Bool = false
    @State private var showingScanner: Bool = false
    @State private var quickAddText: String = ""

    public init(group: SDGroup) {
        self.initialGroup = group
        self._selectedGroup = State(initialValue: group)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Group Selector (if multiple groups exist)
                    if allGroups.count > 1 {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Group")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)

                            Picker("Select Group", selection: $selectedGroup) {
                                ForEach(allGroups) { g in
                                    Text("\(g.emoji) \(g.name)").tag(g)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .frame(height: 44)
                            .background(Color.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .onChange(of: selectedGroup) { _, newGroup in
                                let currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_default"
                                viewModel.setupForNewExpense(group: newGroup, currentUserId: currentUserId)
                            }
                        }
                        .elevatedCard()
                    }

                    // Quick Add NLP Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.purple)
                            Text("Natural Language Quick Add")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 8) {
                            TextField("e.g. Dinner 1200 with Ankit and Riya", text: $quickAddText)
                                .font(.system(size: 14))
                                .textFieldStyle(.roundedBorder)

                            Button("Fill") {
                                applyQuickAdd()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.purple)
                            .disabled(quickAddText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .elevatedCard()

                    // Title & Amount Card
                    VStack(alignment: .leading, spacing: 16) {
                        TextField("What was this for? (e.g. Dinner)", text: Binding(
                            get: { viewModel.title },
                            set: { viewModel.onTitleChanged($0) }
                        ))
                        .font(.system(size: 22, weight: .bold, design: .rounded))

                        Divider()

                        CurrencyTextField(minorUnits: $viewModel.amountMinorUnits, currency: selectedGroup.currency)

                        HStack(spacing: 12) {
                            // Category Picker
                            Menu {
                                ForEach(ExpenseCategory.allCases) { cat in
                                    Button(action: { viewModel.category = cat }) {
                                        Label(cat.displayName, systemImage: cat.systemImage)
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: viewModel.category.systemImage)
                                        .foregroundColor(viewModel.category.color)
                                    Text(viewModel.category.displayName)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.primary)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.surfaceSecondary)
                                .clipShape(Capsule())
                            }

                            // Date Picker
                            DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                    .elevatedCard()

                    // Paid By Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Paid By")
                            .font(.headline)

                        Picker("Paid By", selection: $viewModel.singlePayerId) {
                            ForEach(selectedGroup.members) { m in
                                Text(m.name).tag(m.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 12)
                        .frame(height: 48)
                        .background(Color.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .elevatedCard()

                    // Split Configuration
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Split Configuration")
                            .font(.headline)

                        SplitConfigurationView(group: selectedGroup, viewModel: viewModel)
                    }

                    // Optional Notes & Recurring
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Notes (optional)", text: $viewModel.notes)
                            .textFieldStyle(.roundedBorder)

                        Toggle("Recurring Monthly Expense", isOn: $viewModel.isRecurring)
                    }
                    .elevatedCard()

                    PrimaryButton("Save Expense", icon: "checkmark") {
                        save()
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color.surfaceSecondary.ignoresSafeArea())
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingScanner = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "text.viewfinder")
                            Text("Scan")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                ReceiptScannerView(group: selectedGroup) { scannedItems, tax, total in
                    applyScannedReceipt(items: scannedItems, tax: tax, total: total)
                }
            }
            .onAppear {
                let currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_default"
                viewModel.setupForNewExpense(group: selectedGroup, currentUserId: currentUserId)
            }
            .alert("Cannot Save Expense", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Please check inputs.")
            }
        }
    }

    private func applyQuickAdd() {
        guard let parsed = QuickAddParser.parse(quickAddText, defaultCurrency: selectedGroup.currency) else { return }
        viewModel.onTitleChanged(parsed.title)
        viewModel.amountMinorUnits = parsed.amountMinorUnits
        viewModel.splitType = parsed.splitType

        if !parsed.participantNames.isEmpty {
            var matchedIds: Set<String> = []
            for name in parsed.participantNames {
                if let member = selectedGroup.members.first(where: { $0.name.localizedCaseInsensitiveContains(name) }) {
                    matchedIds.insert(member.id)
                }
            }
            if !matchedIds.isEmpty {
                // Ensure current user is included if participating
                let currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_default"
                matchedIds.insert(currentUserId)
                viewModel.selectedParticipantIds = matchedIds
            }
        }
        HapticManager.notification(.success)
    }

    private func applyScannedReceipt(items: [ScannedReceiptItem], tax: Int64, total: Int64) {
        if viewModel.title.isEmpty {
            viewModel.title = "Receipt Scan (\(items.first?.name ?? "Items"))"
        }
        viewModel.amountMinorUnits = total
        viewModel.splitType = .itemized
        viewModel.itemizedTaxMinorUnits = tax
        viewModel.itemizedList = items.map {
            ItemizedBillItem(
                name: $0.name,
                amountMinorUnits: $0.amountMinorUnits,
                assignedParticipantIds: Set(selectedGroup.members.map { $0.id })
            )
        }
        HapticManager.notification(.success)
    }

    private func save() {
        let currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_default"
        let currentUserName = UserDefaults.standard.string(forKey: "splitease_user_name") ?? "You"

        let success = viewModel.saveExpense(
            group: selectedGroup,
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            modelContext: modelContext
        )

        if success {
            dismiss()
        } else {
            showingErrorAlert = true
        }
    }
}
