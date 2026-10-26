//
//  ProfileSetupView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct ProfileSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: AuthViewModel

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 6) {
                Text("Set Up Your Profile")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("Tell your friends how to identify you and send settlements.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Avatar Live Preview
            HStack(spacing: 16) {
                UserAvatarView(name: viewModel.name.isEmpty ? "You" : viewModel.name, size: 72)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.name.isEmpty ? "Your Name" : viewModel.name)
                        .font(.headline)
                    Text("Avatar initials generated automatically")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)

            // Form Fields
            VStack(spacing: 16) {
                // Name
                VStack(alignment: .leading, spacing: 6) {
                    Text("Full Name")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)

                    TextField("e.g. Ayush Kumar", text: $viewModel.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                // Currency Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Default Currency")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)

                    Picker("Default Currency", selection: $viewModel.selectedCurrency) {
                        ForEach(Currency.allCases) { curr in
                            Text("\(curr.symbol) \(curr.displayName)").tag(curr)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(Color.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                // UPI ID
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("UPI ID (Optional)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("For direct one-tap payments")
                            .font(.caption2)
                            .foregroundColor(.appPrimary)
                    }

                    TextField("e.g. yourname@okhdfcbank", text: $viewModel.upiId)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }

            Spacer()

            PrimaryButton(
                "Save Profile",
                icon: "arrow.right",
                isEnabled: !viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ) {
                viewModel.completeProfile(modelContext: modelContext)
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .background(Color.surfacePrimary)
    }
}
