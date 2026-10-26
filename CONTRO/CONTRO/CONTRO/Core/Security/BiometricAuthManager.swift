//
//  BiometricAuthManager.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation
import LocalAuthentication
import UIKit

@Observable
public final class BiometricAuthManager {
    public static let shared = BiometricAuthManager()

    public var isBiometricAvailable: Bool = false
    public var biometricType: LABiometryType = .none
    public var isAppUnlocked: Bool = true

    public init() {
        checkBiometricAvailability()
    }

    public func checkBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        isBiometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        biometricType = context.biometryType
    }

    public var biometricTitle: String {
        switch biometricType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Biometrics"
        }
    }

    public var biometricIcon: String {
        switch biometricType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "eye"
        default: return "lock.fill"
        }
    }

    @MainActor
    public func authenticate(reason: String = "Unlock SplitEase") async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            isAppUnlocked = true
            return true
        }

        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            isAppUnlocked = success
            if success {
                HapticManager.notification(.success)
            } else {
                HapticManager.notification(.error)
            }
            return success
        } catch {
            isAppUnlocked = false
            HapticManager.notification(.error)
            return false
        }
    }
}
