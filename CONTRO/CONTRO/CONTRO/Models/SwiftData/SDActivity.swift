//
//  SDActivity.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation
import SwiftData

@Model
public final class SDActivity {
    @Attribute(.unique) public var id: String
    public var groupId: String
    public var actorId: String
    public var actorName: String
    public var typeRaw: String
    public var targetExpenseId: String?
    public var targetExpenseTitle: String?
    public var amountMinorUnits: Int64?
    public var message: String
    public var timestamp: Date

    public var group: SDGroup?

    public init(
        id: String = UUID().uuidString,
        groupId: String,
        actorId: String,
        actorName: String,
        typeRaw: String,
        targetExpenseId: String? = nil,
        targetExpenseTitle: String? = nil,
        amountMinorUnits: Int64? = nil,
        message: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.groupId = groupId
        self.actorId = actorId
        self.actorName = actorName
        self.typeRaw = typeRaw
        self.targetExpenseId = targetExpenseId
        self.targetExpenseTitle = targetExpenseTitle
        self.amountMinorUnits = amountMinorUnits
        self.message = message
        self.timestamp = timestamp
    }

    public var type: ActivityType {
        ActivityType(rawValue: typeRaw) ?? .expenseCreated
    }
}
