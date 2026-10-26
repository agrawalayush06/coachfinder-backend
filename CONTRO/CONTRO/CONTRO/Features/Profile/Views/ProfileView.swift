//
//  ProfileView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<SDUser> { $0.isCurrentUser }) private var currentUsers: [SDUser]

    @State private var biometricAuth = BiometricAuthManager.shared
    @State private var enableFaceID: Bool = UserDefaults.standard.bool(forKey: "splitease_enable_biometrics")
    @State private var syncEngine = CloudSyncEngine.shared
    @State private var showingDemoDataAlert: Bool = false

    private var currentUser: SDUser? {
        currentUsers.first
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                // User Card
                Section {
                    HStack(spacing: 16) {
                        UserAvatarView(name: currentUser?.name ?? "Ayush Kumar", size: 64)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentUser?.name ?? "Ayush Kumar")
                                .font(.system(size: 18, weight: .bold, design: .rounded))

                            Text(currentUser?.phoneNumber ?? "+919876543210")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if let upi = currentUser?.upiId {
                                Text("UPI: \(upi)")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundColor(.appPrimary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Cloud Sync Section
                Section("Cloud Sync & Collaboration") {
                    HStack {
                        Label("Cloud Status", systemImage: "icloud.fill")
                            .foregroundColor(.appPrimary)
                        Spacer()
                        StatusBadge(
                            syncEngine.status.rawValue,
                            icon: syncEngine.isSyncing ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill",
                            color: syncEngine.status == .error ? .red : (syncEngine.isSyncing ? .orange : .owedPositive)
                        )
                    }

                    if let lastSync = syncEngine.lastSyncDate {
                        HStack {
                            Text("Last Synced")
                                .font(.subheadline)
                            Spacer()
                            Text(lastSync.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Text("Config Status")
                            .font(.subheadline)
                        Spacer()
                        Text(FirebaseConfig.shared.isConfiguredFromPlist ? "GoogleService-Info.plist" : "Default Fallback")
                            .font(.caption)
                            .foregroundColor(FirebaseConfig.shared.isConfiguredFromPlist ? .owedPositive : .secondary)
                    }

                    HStack {
                        Text("Firebase Project")
                            .font(.subheadline)
                        Spacer()
                        Text(FirebaseConfig.shared.projectId)
                            .font(.caption.monospaced())
                            .foregroundColor(.secondary)
                    }

                    if let msg = syncEngine.syncMessage {
                        Text(msg)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Button(action: {
                        Task {
                            await syncEngine.syncAll(modelContext: modelContext)
                        }
                    }) {
                        HStack {
                            if syncEngine.isSyncing {
                                ProgressView()
                                    .padding(.trailing, 4)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.appPrimary)
                            }
                            Text(syncEngine.isSyncing ? "Syncing..." : "Sync Now with Cloud")
                                .foregroundColor(.primary)
                        }
                    }
                    .disabled(syncEngine.isSyncing)
                }

                // Security & Preferences
                Section("Security") {
                    Toggle(isOn: $enableFaceID) {
                        HStack(spacing: 12) {
                            Image(systemName: biometricAuth.biometricIcon)
                                .foregroundColor(.appPrimary)
                            Text("\(biometricAuth.biometricTitle) App Lock")
                        }
                    }
                    .onChange(of: enableFaceID) { _, enabled in
                        if enabled {
                            Task {
                                let success = await biometricAuth.authenticate(reason: "Enable biometric lock")
                                if success {
                                    UserDefaults.standard.set(true, forKey: "splitease_enable_biometrics")
                                } else {
                                    enableFaceID = false
                                    UserDefaults.standard.set(false, forKey: "splitease_enable_biometrics")
                                }
                            }
                        } else {
                            UserDefaults.standard.set(false, forKey: "splitease_enable_biometrics")
                        }
                    }
                }

                // Demo / Seed Mode
                Section("Developer / Demo Tools") {
                    Button(action: {
                        SeedDataLoader.loadSampleData(modelContext: modelContext, forceReload: true)
                        DataRefreshCoordinator.notifyDataChanged()
                        HapticManager.notification(.success)
                        showingDemoDataAlert = true
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange)
                            Text("Populate Realistic Seed Data")
                                .foregroundColor(.primary)
                        }
                    }

                    Text("Loads Goa Vacation trip, Flatmates, and sample friends with full chart history and settlements.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // App Info
                Section("About SplitEase") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Production Build)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Architecture")
                        Spacer()
                        Text("SwiftUI + SwiftData + Apple Vision")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Currency Precision")
                        Spacer()
                        Text("Int64 Minor Units (Paise/Cents)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Profile & Settings")
            .alert("Sample Data Populated!", isPresented: $showingDemoDataAlert) {
                Button("Great!", role: .cancel) {}
            } message: {
                Text("Goa Vacation 2026 and Indiranagar Flatmates have been loaded with realistic expenses and debts.")
            }
        }
    }
}
