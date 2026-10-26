//
//  UserAvatarView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public struct UserAvatarView: View {
    let name: String
    var avatarUrl: String? = nil
    var size: CGFloat = 44
    var isPending: Bool = false

    public init(name: String, avatarUrl: String? = nil, size: CGFloat = 44, isPending: Bool = false) {
        self.name = name
        self.avatarUrl = avatarUrl
        self.size = size
        self.isPending = isPending
    }

    public var body: some View {
        ZStack {
            if let avatarUrl = avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        initialsView
                    }
                }
            } else {
                initialsView
            }

            if isPending {
                Circle()
                    .strokeBorder(Color.orange, style: StrokeStyle(lineWidth: 2, dash: [4]))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var initialsView: some View {
        ZStack {
            Circle()
                .fill(gradientForName(name))
            Text(initials(for: name))
                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ").map { String($0) }
        if parts.count >= 2 {
            let first = parts[0].prefix(1)
            let second = parts[1].prefix(1)
            return "\(first)\(second)".uppercased()
        } else if let first = parts.first {
            return String(first.prefix(2)).uppercased()
        }
        return "??"
    }

    private func gradientForName(_ name: String) -> LinearGradient {
        let hash = abs(name.hashValue)
        let colors: [[Color]] = [
            [Color(red: 0.35, green: 0.38, blue: 0.95), Color(red: 0.55, green: 0.38, blue: 0.95)], // Indigo/Purple
            [Color(red: 0.95, green: 0.40, blue: 0.55), Color(red: 0.95, green: 0.60, blue: 0.40)], // Rose/Coral
            [Color(red: 0.16, green: 0.73, blue: 0.44), Color(red: 0.20, green: 0.78, blue: 0.65)], // Emerald/Teal
            [Color(red: 0.20, green: 0.60, blue: 0.95), Color(red: 0.16, green: 0.73, blue: 0.95)], // Blue/Cyan
            [Color(red: 0.95, green: 0.65, blue: 0.20), Color(red: 0.95, green: 0.45, blue: 0.20)], // Amber/Orange
        ]
        let pair = colors[hash % colors.count]
        return LinearGradient(colors: pair, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
