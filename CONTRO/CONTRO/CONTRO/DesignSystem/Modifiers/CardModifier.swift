//
//  CardModifier.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public struct ElevatedCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

public extension View {
    func elevatedCard(cornerRadius: CGFloat = 16, padding: CGFloat = 16) -> some View {
        modifier(ElevatedCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}
