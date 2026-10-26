//
//  PrimaryButton.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public enum ButtonStyleVariant {
    case primary
    case secondary
    case destructive
    case outline
}

public struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var variant: ButtonStyleVariant = .primary
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        variant: ButtonStyleVariant = .primary,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: {
            guard !isLoading && isEnabled else { return }
            HapticManager.impact(.medium)
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: variant == .outline ? 1.5 : 0)
            )
        }
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.5)
        .buttonStyle(ScaleTouchStyle())
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary: return Color.appPrimary
        case .secondary: return Color.surfaceSecondary
        case .destructive: return Color.owedNegative
        case .outline: return Color.clear
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary, .destructive: return .white
        case .secondary, .outline: return Color.primary
        }
    }

    private var borderColor: Color {
        switch variant {
        case .outline: return Color.appPrimary
        default: return .clear
        }
    }
}

public struct ScaleTouchStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
