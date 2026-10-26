//
//  PhoneLoginView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public struct PhoneLoginView: View {
    @Bindable var viewModel: AuthViewModel

    @State private var showingCountryPicker: Bool = false

    public var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    HapticManager.selection()
                    viewModel.currentStep = .intro
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 8)

                Text("Enter Mobile Number")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("We will send a 6-digit OTP code to verify your phone number.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Input Row
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    // Country Code Button
                    Button(action: {
                        showingCountryPicker = true
                    }) {
                        HStack(spacing: 6) {
                            Text(currentCountryFlag)
                                .font(.system(size: 20))
                            Text(viewModel.selectedCountryCode)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 54)
                        .background(Color.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // Phone text field
                    HStack {
                        TextField("98765 43210", text: $viewModel.phoneNumber)
                            .keyboardType(.numberPad)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))

                        if !viewModel.phoneNumber.isEmpty {
                            Button(action: { viewModel.phoneNumber = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 54)
                    .background(Color.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                if let err = viewModel.phoneErrorMessage {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }

            Spacer()

            PrimaryButton(
                "Send Verification Code",
                icon: "arrow.right",
                isLoading: viewModel.isSendingOTP,
                isEnabled: viewModel.isPhoneValid
            ) {
                viewModel.sendOTP()
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .background(Color.surfacePrimary)
        .sheet(isPresented: $showingCountryPicker) {
            countryPickerSheet
        }
    }

    private var currentCountryFlag: String {
        viewModel.availableCountryCodes.first(where: { $0.code == viewModel.selectedCountryCode })?.flag ?? "🇮🇳"
    }

    private var countryPickerSheet: some View {
        NavigationStack {
            List(viewModel.availableCountryCodes, id: \.code) { item in
                Button(action: {
                    viewModel.selectedCountryCode = item.code
                    showingCountryPicker = false
                }) {
                    HStack {
                        Text(item.flag)
                            .font(.title3)
                        Text(item.name)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(item.code)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showingCountryPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
