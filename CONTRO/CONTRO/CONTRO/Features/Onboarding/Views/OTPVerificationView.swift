//
//  OTPVerificationView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct OTPVerificationView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: AuthViewModel

    @FocusState private var focusedIndex: Int?

    public var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    HapticManager.selection()
                    viewModel.currentStep = .phone
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 8)

                Text("Enter 6-Digit Code")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("Code sent to \(viewModel.selectedCountryCode) \(viewModel.phoneNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // 6-digit boxes
            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { idx in
                    TextField("", text: Binding(
                        get: { viewModel.otpDigits[idx] },
                        set: { newVal in
                            handleDigitInput(index: idx, newValue: newVal)
                        }
                    ))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(focusedIndex == idx ? Color.appPrimary : Color.clear, lineWidth: 2)
                    )
                    .focused($focusedIndex, equals: idx)
                }
            }
            .onAppear {
                focusedIndex = 0
            }

            // Quick Auto-Fill for Testing
            Button(action: {
                let testCode = ["1", "2", "3", "4", "5", "6"]
                viewModel.otpDigits = testCode
                HapticManager.notification(.success)
                viewModel.verifyOTP(modelContext: modelContext)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "wand.and.stars")
                    Text("Auto-fill Test Code (123456)")
                }
                .font(.caption)
                .foregroundColor(.appPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.appPrimary.opacity(0.1))
                .clipShape(Capsule())
            }

            if let err = viewModel.otpErrorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            // Timer & Resend
            HStack {
                if viewModel.canResend {
                    Button("Resend Code") {
                        viewModel.resendOTP()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.appPrimary)
                } else {
                    Text("Resend code in \(viewModel.timerRemaining)s")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            PrimaryButton(
                "Verify Code",
                icon: "checkmark",
                isLoading: viewModel.isVerifyingOTP,
                isEnabled: viewModel.otpDigits.joined().count == 6
            ) {
                viewModel.verifyOTP(modelContext: modelContext)
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .background(Color.surfacePrimary)
    }

    private func handleDigitInput(index: Int, newValue: String) {
        if newValue.count > 1 {
            // Handle paste of whole code
            let chars = Array(newValue.filter { $0.isNumber })
            for (offset, char) in chars.prefix(6).enumerated() {
                viewModel.otpDigits[offset] = String(char)
            }
            if chars.count >= 6 {
                focusedIndex = nil
                viewModel.verifyOTP(modelContext: modelContext)
            }
            return
        }

        viewModel.otpDigits[index] = newValue

        if !newValue.isEmpty {
            if index < 5 {
                focusedIndex = index + 1
            } else {
                focusedIndex = nil
                viewModel.verifyOTP(modelContext: modelContext)
            }
        } else {
            if index > 0 {
                focusedIndex = index - 1
            }
        }
    }
}
