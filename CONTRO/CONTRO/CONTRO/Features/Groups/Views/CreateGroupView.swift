//
//  CreateGroupView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var emoji: String = "🏖️"
    @State private var selectedCategory: GroupCategory = .trip
    @State private var selectedCurrency: Currency = .inr
    @State private var simplifyDebts: Bool = true

    private let sampleEmojis = ["🏖️", "🏠", "🍕", "✈️", "🎉", "🚗", "💼", "🏕️", "🍹", "🛍️"]

    public var body: some View {
        NavigationStack {
            Form {
                Section("Group Details") {
                    HStack {
                        Text(emoji)
                            .font(.system(size: 32))
                        TextField("Group Name (e.g. Goa Vacation)", text: $name)
                            .font(.headline)
                    }

                    // Emoji selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(sampleEmojis, id: \.self) { e in
                                Button(action: {
                                    HapticManager.selection()
                                    emoji = e
                                }) {
                                    Text(e)
                                        .font(.system(size: 26))
                                        .padding(8)
                                        .background(emoji == e ? Color.appPrimary.opacity(0.2) : Color.clear)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                }

                Section("Category") {
                    Picker("Group Type", selection: $selectedCategory) {
                        ForEach(GroupCategory.allCases) { cat in
                            Text("\(cat.defaultEmoji) \(cat.displayName)").tag(cat)
                        }
                    }
                }

                Section("Currency & Settings") {
                    Picker("Default Currency", selection: $selectedCurrency) {
                        ForEach(Currency.allCases) { curr in
                            Text("\(curr.symbol) \(curr.displayName)").tag(curr)
                        }
                    }

                    Toggle("Simplify Debts", isOn: $simplifyDebts)
                }
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createGroup()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func createGroup() {
        let currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_default"
        let currentUserName = UserDefaults.standard.string(forKey: "splitease_user_name") ?? "You"
        let currentUserPhone = UserDefaults.standard.string(forKey: "splitease_phone") ?? "+919876543210"

        let selfMember = GroupMember(
            id: currentUserId,
            name: currentUserName,
            phoneNumber: currentUserPhone,
            role: "admin"
        )

        let newGroup = SDGroup(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: emoji,
            categoryRaw: selectedCategory.rawValue,
            defaultCurrencyCode: selectedCurrency.rawValue,
            createdByUserId: currentUserId,
            simplifyDebts: simplifyDebts,
            members: [selfMember]
        )

        modelContext.insert(newGroup)
        try? modelContext.save()
        DataRefreshCoordinator.notifyDataChanged()
        HapticManager.notification(.success)
        dismiss()
    }
}
