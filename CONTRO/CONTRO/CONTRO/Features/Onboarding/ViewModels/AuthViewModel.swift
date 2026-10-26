//
//  AuthViewModel.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData
import LocalAuthentication

public enum OnboardingStep: Int, CaseIterable, Sendable {
    case intro = 0
    case phone = 1
    case otp = 2
    case profile = 3
    case permissions = 4
    case completed = 5
}

@Observable
public final class AuthViewModel {
    public var currentStep: OnboardingStep = .intro

    // Phone Step
    public var selectedCountryCode: String = "+91"
    public var phoneNumber: String = ""
    public var availableCountryCodes: [(code: String, flag: String, name: String)] = [
        ("+91", "🇮🇳", "India"),
        ("+1", "🇺🇸", "United States"),
        ("+44", "🇬🇧", "United Kingdom"),
        ("+65", "🇸🇬", "Singapore"),
        ("+971", "🇦🇪", "United Arab Emirates"),
        ("+61", "🇦🇺", "Australia"),
        ("+1", "🇨🇦", "Canada"),
        ("+49", "🇩🇪", "Germany"),
        ("+81", "🇯🇵", "Japan")
    ]
    public var isSendingOTP: Bool = false
    public var phoneErrorMessage: String? = nil

    // OTP Step
    public var otpDigits: [String] = Array(repeating: "", count: 6)
    public var timerRemaining: Int = 30
    public var canResend: Bool = false
    public var isVerifyingOTP: Bool = false
    public var otpErrorMessage: String? = nil
    private var timerTask: Task<Void, Never>? = nil

    // Profile Setup Step
    public var name: String = ""
    public var selectedCurrency: Currency = .inr
    public var upiId: String = ""
    public var enableBiometrics: Bool = false

    // Permissions Step
    public var isContactsGranted: Bool = false
    public var isCameraGranted: Bool = false
    public var isNotificationsGranted: Bool = false

    // Authentication session state
    public var isAuthenticated: Bool = false
    public var currentUserId: String = ""

    public init() {
        checkSession()
    }

    public func checkSession() {
        if UserDefaults.standard.bool(forKey: "splitease_is_logged_in") {
            currentUserId = UserDefaults.standard.string(forKey: "splitease_user_id") ?? "usr_default"
            isAuthenticated = true
            currentStep = .completed
        }
    }

    // MARK: - Phone Actions
    public var isPhoneValid: Bool {
        let digits = phoneNumber.filter { $0.isNumber }
        return digits.count >= 10
    }

    public func sendOTP() {
        guard isPhoneValid else {
            phoneErrorMessage = "Please enter a valid 10-digit mobile number."
            HapticManager.notification(.error)
            return
        }

        phoneErrorMessage = nil
        isSendingOTP = true
        HapticManager.impact(.medium)

        Task { @MainActor in
            // Simulate network OTP dispatch or integrate Firebase Phone Auth
            try? await Task.sleep(nanoseconds: 600_000_000)
            isSendingOTP = false
            currentStep = .otp
            startResendTimer()
            HapticManager.notification(.success)
        }
    }

    // MARK: - OTP Actions
    public func startResendTimer() {
        timerRemaining = 30
        canResend = false
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while timerRemaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                timerRemaining -= 1
            }
            canResend = true
        }
    }

    public func resendOTP() {
        guard canResend else { return }
        HapticManager.impact(.medium)
        startResendTimer()
    }

    public func verifyOTP(modelContext: ModelContext) {
        let code = otpDigits.joined()
        guard code.count == 6 else {
            otpErrorMessage = "Please enter the full 6-digit verification code."
            HapticManager.notification(.error)
            return
        }

        isVerifyingOTP = true
        otpErrorMessage = nil

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 700_000_000)
            isVerifyingOTP = false

            // Default demo verification: accepts "123456" or any 6 digits for testing
            HapticManager.notification(.success)
            currentStep = .profile
        }
    }

    // MARK: - Profile & Finish
    public func completeProfile(modelContext: ModelContext) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return
        }

        let fullPhone = "\(selectedCountryCode)\(phoneNumber)"
        let newUserId = "usr_\(UUID().uuidString.prefix(8))"
        let user = SDUser(
            id: newUserId,
            phoneNumber: fullPhone,
            name: trimmedName,
            defaultCurrencyCode: selectedCurrency.rawValue,
            upiId: upiId.isEmpty ? nil : upiId,
            isCurrentUser: true
        )
        modelContext.insert(user)
        try? modelContext.save()

        UserDefaults.standard.set(true, forKey: "splitease_is_logged_in")
        UserDefaults.standard.set(newUserId, forKey: "splitease_user_id")
        UserDefaults.standard.set(trimmedName, forKey: "splitease_user_name")
        UserDefaults.standard.set(fullPhone, forKey: "splitease_phone")
        UserDefaults.standard.set(selectedCurrency.rawValue, forKey: "splitease_currency")
        if !upiId.isEmpty {
            UserDefaults.standard.set(upiId, forKey: "splitease_upi_id")
        }

        currentUserId = newUserId
        HapticManager.notification(.success)
        currentStep = .permissions
    }

    public func finishOnboarding() {
        HapticManager.notification(.success)
        isAuthenticated = true
        currentStep = .completed
    }

    public func signOut(modelContext: ModelContext) {
        UserDefaults.standard.set(false, forKey: "splitease_is_logged_in")
        UserDefaults.standard.removeObject(forKey: "splitease_user_id")
        isAuthenticated = false
        currentStep = .intro
        phoneNumber = ""
        otpDigits = Array(repeating: "", count: 6)
        name = ""
        upiId = ""
    }
}
