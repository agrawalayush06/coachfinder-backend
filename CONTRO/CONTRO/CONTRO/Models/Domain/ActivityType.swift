//
//  ActivityType.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public enum ActivityType: String, CaseIterable, Codable, Identifiable, Sendable {
    case expenseCreated = "expense_created"
    case expenseEdited = "expense_edited"
    case expenseDeleted = "expense_deleted"
    case settled = "settled"
    case memberJoined = "member_joined"
    case groupCreated = "group_created"

    public var id: String { rawValue }

    public var systemImage: String {
        switch self {
        case .expenseCreated: return "plus.circle.fill"
        case .expenseEdited: return "pencil.circle.fill"
        case .expenseDeleted: return "trash.circle.fill"
        case .settled: return "checkmark.seal.fill"
        case .memberJoined: return "person.badge.plus.fill"
        case .groupCreated: return "folder.badge.plus"
        }
    }

    public var color: Color {
        switch self {
        case .expenseCreated: return .blue
        case .expenseEdited: return .orange
        case .expenseDeleted: return .red
        case .settled: return .green
        case .memberJoined: return .purple
        case .groupCreated: return .indigo
        }
    }
}
