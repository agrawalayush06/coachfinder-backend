//
//  ContentView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var authViewModel = AuthViewModel()
    @State private var biometricAuth = BiometricAuthManager.shared

    private var isBiometricEnabled: Bool {
        UserDefaults.standard.bool(forKey: "splitease_enable_biometrics")
    }

    var body: some View {
        Group {
            if authViewModel.currentStep == .completed || authViewModel.isAuthenticated {
                if isBiometricEnabled && !biometricAuth.isAppUnlocked {
                    biometricLockView
                } else {
                    MainTabView()
                }
            } else {
                OnboardingFlowView(viewModel: authViewModel)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active && isBiometricEnabled {
                Task {
                    _ = await biometricAuth.authenticate()
                }
            } else if newPhase == .background && isBiometricEnabled {
                biometricAuth.isAppUnlocked = false
            }
        }
        .task {
            if isBiometricEnabled {
                _ = await biometricAuth.authenticate()
            }
        }
    }

    private var biometricLockView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: biometricAuth.biometricIcon)
                .font(.system(size: 64))
                .foregroundColor(.appPrimary)
            Text("SplitEase is Locked")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Text("Authenticate to access your expenses and balances.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button(action: {
                Task {
                    _ = await biometricAuth.authenticate()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: biometricAuth.biometricIcon)
                    Text("Unlock with \(biometricAuth.biometricTitle)")
                }
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color.appPrimary)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            .padding(.top, 16)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surfacePrimary.ignoresSafeArea())
    }
}
