//
//  StatusBadge.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public struct StatusBadge: View {
    let title: String
    var icon: String? = nil
    var color: Color = .appPrimary

    public init(_ title: String, icon: String? = nil, color: Color = .appPrimary) {
        self.title = title
        self.icon = icon
        self.color = color
    }

    public var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
            }
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}
