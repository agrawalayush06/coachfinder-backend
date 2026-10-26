//
//  GroupSettingsView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct GroupSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var group: SDGroup

    @State private var showingAddMemberSheet: Bool = false
    @State private var newMemberName: String = ""
    @State private var newMemberPhone: String = ""

    public var body: some View {
        NavigationStack {
            Form {
                Section("Group Information") {
                    HStack {
                        Text("Group Emoji")
                        Spacer()
                        TextField("Emoji", text: $group.emoji)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Group Name")
                        Spacer()
                        TextField("Name", text: $group.name)
                            .multilineTextAlignment(.trailing)
                    }

                    Picker("Default Currency", selection: $group.defaultCurrencyCode) {
                        ForEach(Currency.allCases) { curr in
                            Text("\(curr.symbol) \(curr.displayName)").tag(curr.rawValue)
                        }
                    }
                }

                Section("Debt Settings") {
                    Toggle("Simplify Debts", isOn: $group.simplifyDebts)
                    Text("Minimizes transactions using our bipartite graph algorithm so members pay fewer people.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Section {
                    Button(role: .destructive) {
                        group.isArchived = true
                        try? modelContext.save()
                        HapticManager.notification(.warning)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "archivebox.fill")
                            Text("Archive Group")
                        }
                    }
                }
            }
            .navigationTitle("Group Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
