//
//  PermissionsView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public struct PermissionsView: View {
    @Bindable var viewModel: AuthViewModel

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 6) {
                Text("Enable App Permissions")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("SplitEase uses these to make expense sharing seamless.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 16) {
                permissionCard(
                    icon: "person.crop.circle.badge.plus",
                    color: .blue,
                    title: "Access Contacts",
                    subtitle: "Easily select friends to split bills without typing numbers manually.",
                    isGranted: viewModel.isContactsGranted
                ) {
                    viewModel.isContactsGranted.toggle()
                    HapticManager.selection()
                }

                permissionCard(
                    icon: "camera.viewfinder",
                    color: .purple,
                    title: "Camera & Receipt Scanner",
                    subtitle: "Scan paper receipts with Apple Vision OCR to auto-extract items.",
                    isGranted: viewModel.isCameraGranted
                ) {
                    viewModel.isCameraGranted.toggle()
                    HapticManager.selection()
                }

                permissionCard(
                    icon: "bell.badge.fill",
                    color: .orange,
                    title: "Smart Notifications",
                    subtitle: "Receive alerts when friends add expenses or settle their balances.",
                    isGranted: viewModel.isNotificationsGranted
                ) {
                    viewModel.isNotificationsGranted.toggle()
                    HapticManager.selection()
                }
            }

            Spacer()

            PrimaryButton("Enter SplitEase", icon: "sparkles") {
                viewModel.finishOnboarding()
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .background(Color.surfacePrimary)
    }

    @ViewBuilder
    private func permissionCard(
        icon: String,
        color: Color,
        title: String,
        subtitle: String,
        isGranted: Bool,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Button(action: action) {
                Image(systemName: isGranted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isGranted ? .owedPositive : .secondary)
            }
        }
        .elevatedCard()
    }
}
