//
//  IntroCarouselView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public struct IntroSlideItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let systemImage: String
    public let gradientColors: [Color]
    public let badgeText: String
}

public struct IntroCarouselView: View {
    @Bindable var viewModel: AuthViewModel

    @State private var currentSlide: Int = 0

    private let slides: [IntroSlideItem] = [
        IntroSlideItem(
            title: "Split Bills with Absolute Precision",
            subtitle: "Equal, exact, percentage, shares, itemized receipt breakdown, and adjustments with zero penny loss.",
            systemImage: "divide.circle.fill",
            gradientColors: [Color.appPrimary, Color.purple],
            badgeText: "6 Split Modes"
        ),
        IntroSlideItem(
            title: "On-Device AI Receipt Scanner",
            subtitle: "Capture paper bills with Apple Vision OCR. Tap to assign items to roommates and friends instantly.",
            systemImage: "text.viewfinder",
            gradientColors: [Color.blue, Color.teal],
            badgeText: "Apple Vision OCR"
        ),
        IntroSlideItem(
            title: "Debt Simplification & UPI",
            subtitle: "Minimize messy group transactions into fewer direct payments. Settle via GPay, PhonePe, or Paytm in one tap.",
            systemImage: "qrcode",
            gradientColors: [Color.owedPositive, Color.teal],
            badgeText: "One-Tap Settle"
        )
    ]

    public var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Button("Skip") {
                    HapticManager.selection()
                    viewModel.currentStep = .phone
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            TabView(selection: $currentSlide) {
                ForEach(0..<slides.count, id: \.self) { idx in
                    slideView(slide: slides[idx])
                        .tag(idx)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            // Custom Page Dots
            HStack(spacing: 8) {
                ForEach(0..<slides.count, id: \.self) { idx in
                    Capsule()
                        .fill(idx == currentSlide ? Color.appPrimary : Color.secondary.opacity(0.3))
                        .frame(width: idx == currentSlide ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentSlide)
                }
            }

            VStack(spacing: 12) {
                PrimaryButton("Get Started with Phone", icon: "phone.fill") {
                    viewModel.currentStep = .phone
                }

                Text("By continuing, you agree to our Terms and Privacy Policy.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.surfacePrimary)
    }

    @ViewBuilder
    private func slideView(slide: IntroSlideItem) -> some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: slide.gradientColors.map { $0.opacity(0.18) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 220, height: 220)

                Image(systemName: slide.systemImage)
                    .font(.system(size: 80, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: slide.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: slide.gradientColors.first?.opacity(0.3) ?? .clear, radius: 16, x: 0, y: 8)
            }

            VStack(spacing: 12) {
                StatusBadge(slide.badgeText, icon: "sparkles", color: slide.gradientColors.first ?? .appPrimary)

                Text(slide.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Text(slide.subtitle)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }

            Spacer()
        }
    }
}
