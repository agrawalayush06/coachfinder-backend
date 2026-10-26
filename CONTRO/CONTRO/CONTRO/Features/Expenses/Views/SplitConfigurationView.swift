//
//  SplitConfigurationView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public struct SplitConfigurationView: View {
    let group: SDGroup
    @Bindable var viewModel: ExpenseViewModel

    @State private var newItemName: String = ""
    @State private var newItemAmount: Int64 = 0

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Split Type Selector
            Picker("Split Type", selection: $viewModel.splitType) {
                ForEach(SplitType.allCases) { type in
                    Text(type.title).tag(type)
                }
            }
            .pickerStyle(.menu)
            .padding(.horizontal, 12)
            .frame(height: 48)
            .background(Color.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(viewModel.splitType.subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)

            Divider()

            switch viewModel.splitType {
            case .equal:
                equalSplitEditor
            case .exact:
                exactSplitEditor
            case .percentage:
                percentageSplitEditor
            case .shares:
                sharesSplitEditor
            case .itemized:
                itemizedSplitEditor
            case .adjustment:
                adjustmentsSplitEditor
            }
        }
        .elevatedCard()
    }

    // MARK: - 1. Equal Split
    private var equalSplitEditor: some View {
        VStack(spacing: 8) {
            ForEach(group.members) { member in
                let isSelected = viewModel.selectedParticipantIds.contains(member.id)
                Button(action: {
                    HapticManager.selection()
                    if isSelected {
                        viewModel.selectedParticipantIds.remove(member.id)
                    } else {
                        viewModel.selectedParticipantIds.insert(member.id)
                    }
                }) {
                    HStack {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .appPrimary : .secondary)
                            .font(.system(size: 20))

                        UserAvatarView(name: member.name, size: 32)

                        Text(member.name)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)

                        Spacer()

                        if isSelected && !viewModel.selectedParticipantIds.isEmpty {
                            let perPerson = viewModel.amountMinorUnits / Int64(viewModel.selectedParticipantIds.count)
                            Text("\(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(perPerson, currency: group.currency)))")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - 2. Exact Split
    private var exactSplitEditor: some View {
        VStack(spacing: 12) {
            let currentSum = viewModel.exactAmounts.values.reduce(0, +)
            let diff = viewModel.amountMinorUnits - currentSum

            HStack {
                Text(diff == 0 ? "Amounts match total!" : (diff > 0 ? "\(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(diff, currency: group.currency))) left to allocate" : "\(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(abs(diff), currency: group.currency))) over total"))
                    .font(.caption.weight(.bold))
                    .foregroundColor(diff == 0 ? .owedPositive : .owedNegative)
                Spacer()
            }

            ForEach(group.members) { member in
                ExactAmountRow(
                    member: member,
                    currency: group.currency,
                    amount: Binding(
                        get: { viewModel.exactAmounts[member.id] ?? 0 },
                        set: { viewModel.exactAmounts[member.id] = $0 }
                    )
                )
            }
        }
    }

    // MARK: - 3. Percentage Split
    private var percentageSplitEditor: some View {
        VStack(spacing: 12) {
            let currentSumPct = viewModel.percentages.values.reduce(0, +)
            HStack {
                Text(String(format: "Total: %.1f%% / 100%%", currentSumPct))
                    .font(.caption.weight(.bold))
                    .foregroundColor(abs(currentSumPct - 100.0) < 0.1 ? .owedPositive : .owedNegative)
                Spacer()
            }

            ForEach(group.members) { member in
                PercentageRow(
                    member: member,
                    percentage: Binding(
                        get: { viewModel.percentages[member.id] ?? 0.0 },
                        set: { viewModel.percentages[member.id] = $0 }
                    )
                )
            }
        }
    }

    // MARK: - 4. Shares Split
    private var sharesSplitEditor: some View {
        VStack(spacing: 12) {
            let totalShares = viewModel.shares.values.reduce(0, +)
            Text("Total Shares: \(totalShares)")
                .font(.caption.weight(.bold))
                .foregroundColor(.secondary)

            ForEach(group.members) { member in
                HStack {
                    UserAvatarView(name: member.name, size: 32)
                    Text(member.name)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))

                    Spacer()

                    Stepper(value: Binding(
                        get: { viewModel.shares[member.id] ?? 1 },
                        set: { viewModel.shares[member.id] = $0 }
                    ), in: 0...50) {
                        Text("\(viewModel.shares[member.id] ?? 1) share\( (viewModel.shares[member.id] ?? 1) == 1 ? "" : "s")")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
            }
        }
    }

    // MARK: - 5. Itemized Split
    private var itemizedSplitEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Line Items")
                .font(.subheadline.weight(.semibold))

            ForEach(viewModel.itemizedList) { item in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(item.name)
                            .font(.system(size: 14, weight: .bold))
                        Spacer()
                        Text("\(group.currency.symbol)\(String(format: "%.2f", MinorUnits.toMajorDouble(item.amountMinorUnits, currency: group.currency)))")
                            .font(.system(size: 14, weight: .bold))
                    }

                    // Assigned avatar row
                    HStack(spacing: 6) {
                        ForEach(group.members) { m in
                            let isAssigned = item.assignedParticipantIds.contains(m.id)
                            Button(action: {
                                if let idx = viewModel.itemizedList.firstIndex(where: { $0.id == item.id }) {
                                    if isAssigned {
                                        viewModel.itemizedList[idx].assignedParticipantIds.remove(m.id)
                                    } else {
                                        viewModel.itemizedList[idx].assignedParticipantIds.insert(m.id)
                                    }
                                }
                            }) {
                                Text(m.name.prefix(1))
                                    .font(.caption2.bold())
                                    .frame(width: 26, height: 26)
                                    .background(isAssigned ? Color.appPrimary : Color.surfaceSecondary)
                                    .foregroundColor(isAssigned ? .white : .secondary)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .padding(8)
                .background(Color.surfaceSecondary.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Quick add item
            HStack(spacing: 8) {
                TextField("Item name (e.g. Burger)", text: $newItemName)
                    .textFieldStyle(.roundedBorder)

                TextField("Price", text: Binding(
                    get: { newItemAmount > 0 ? String(format: "%.2f", MinorUnits.toMajorDouble(newItemAmount, currency: group.currency)) : "" },
                    set: { newItemAmount = MinorUnits.parse($0, currency: group.currency) ?? 0 }
                ))
                .keyboardType(.decimalPad)
                .frame(width: 70)
                .textFieldStyle(.roundedBorder)

                Button("Add") {
                    guard !newItemName.isEmpty, newItemAmount > 0 else { return }
                    viewModel.itemizedList.append(
                        ItemizedBillItem(
                            name: newItemName,
                            amountMinorUnits: newItemAmount,
                            assignedParticipantIds: Set(group.members.map { $0.id })
                        )
                    )
                    newItemName = ""
                    newItemAmount = 0
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    // MARK: - 6. Adjustments Split
    private var adjustmentsSplitEditor: some View {
        VStack(spacing: 12) {
            Text("Adjustments are added/subtracted after equal split.")
                .font(.caption2)
                .foregroundColor(.secondary)

            ForEach(group.members) { member in
                AdjustmentRow(
                    member: member,
                    currency: group.currency,
                    adjustment: Binding(
                        get: { viewModel.adjustments[member.id] ?? 0 },
                        set: { viewModel.adjustments[member.id] = $0 }
                    )
                )
            }
        }
    }
}

// MARK: - Dedicated Helper Rows with Local State for Smooth Typing
struct ExactAmountRow: View {
    let member: GroupMember
    let currency: Currency
    @Binding var amount: Int64
    @State private var text: String = ""

    var body: some View {
        HStack {
            UserAvatarView(name: member.name, size: 32)
            Text(member.name)
                .font(.system(size: 15, weight: .semibold, design: .rounded))

            Spacer()

            Text(currency.symbol)
                .foregroundColor(.secondary)

            TextField("0.00", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .textFieldStyle(.roundedBorder)
                .onAppear {
                    if amount > 0 {
                        text = String(format: "%.2f", MinorUnits.toMajorDouble(amount, currency: currency))
                    }
                }
                .onChange(of: text) { _, newStr in
                    if let parsed = MinorUnits.parse(newStr, currency: currency) {
                        amount = parsed
                    } else if newStr.isEmpty {
                        amount = 0
                    }
                }
                .onChange(of: amount) { _, newAmt in
                    if MinorUnits.parse(text, currency: currency) != newAmt {
                        text = newAmt > 0 ? String(format: "%.2f", MinorUnits.toMajorDouble(newAmt, currency: currency)) : ""
                    }
                }
        }
    }
}

struct PercentageRow: View {
    let member: GroupMember
    @Binding var percentage: Double
    @State private var text: String = ""

    var body: some View {
        HStack {
            UserAvatarView(name: member.name, size: 32)
            Text(member.name)
                .font(.system(size: 15, weight: .semibold, design: .rounded))

            Spacer()

            TextField("0", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
                .textFieldStyle(.roundedBorder)
                .onAppear {
                    if percentage > 0 {
                        text = String(format: "%.1f", percentage)
                    }
                }
                .onChange(of: text) { _, newStr in
                    percentage = Double(newStr) ?? 0.0
                }
                .onChange(of: percentage) { _, newPct in
                    if (Double(text) ?? -1.0) != newPct {
                        text = newPct > 0 ? String(format: "%.1f", newPct) : ""
                    }
                }

            Text("%")
                .foregroundColor(.secondary)
        }
    }
}

struct AdjustmentRow: View {
    let member: GroupMember
    let currency: Currency
    @Binding var adjustment: Int64
    @State private var text: String = ""

    var body: some View {
        HStack {
            UserAvatarView(name: member.name, size: 32)
            Text(member.name)
                .font(.system(size: 15, weight: .semibold, design: .rounded))

            Spacer()

            TextField("+/- 0", text: $text)
                .keyboardType(.numbersAndPunctuation)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .textFieldStyle(.roundedBorder)
                .onAppear {
                    if adjustment != 0 {
                        text = String(format: "%.2f", MinorUnits.toMajorDouble(adjustment, currency: currency))
                    }
                }
                .onChange(of: text) { _, newStr in
                    if let parsed = MinorUnits.parse(newStr, currency: currency) {
                        let isNegative = newStr.trimmingCharacters(in: .whitespaces).hasPrefix("-")
                        adjustment = isNegative ? -abs(parsed) : parsed
                    } else if newStr.isEmpty {
                        adjustment = 0
                    }
                }
                .onChange(of: adjustment) { _, newAdj in
                    if MinorUnits.parse(text, currency: currency) != newAdj {
                        text = newAdj != 0 ? String(format: "%.2f", MinorUnits.toMajorDouble(newAdj, currency: currency)) : ""
                    }
                }
        }
    }
}
