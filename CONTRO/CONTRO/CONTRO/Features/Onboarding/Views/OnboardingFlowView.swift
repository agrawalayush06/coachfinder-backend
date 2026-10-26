//
//  OnboardingFlowView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public struct OnboardingFlowView: View {
    @Bindable var viewModel: AuthViewModel

    public var body: some View {
        ZStack {
            switch viewModel.currentStep {
            case .intro:
                IntroCarouselView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
            case .phone:
                PhoneLoginView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .otp:
                OTPVerificationView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .profile:
                ProfileSetupView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .permissions:
                PermissionsView(viewModel: viewModel)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
            case .completed:
                EmptyView()
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.currentStep)
    }
}
