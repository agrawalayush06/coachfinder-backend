//
//  SDGroup.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation
import SwiftData

public struct GroupMember: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var name: String
    public var phoneNumber: String
    public var role: String // admin, member
    public var isPending: Bool
    public var upiId: String?

    public init(
        id: String = UUID().uuidString,
        name: String,
        phoneNumber: String,
        role: String = "member",
        isPending: Bool = false,
        upiId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.role = role
        self.isPending = isPending
        self.upiId = upiId
    }
}

@Model
public final class SDGroup {
    @Attribute(.unique) public var id: String
    public var name: String
    public var emoji: String
    public var coverImageUrl: String?
    public var categoryRaw: String
    public var defaultCurrencyCode: String
    public var createdByUserId: String
    public var simplifyDebts: Bool
    public var isArchived: Bool
    public var membersJSON: String
    public var createdAt: Date
    public var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \SDExpense.group)
    public var expenses: [SDExpense] = []

    @Relationship(deleteRule: .cascade, inverse: \SDSettlement.group)
    public var settlements: [SDSettlement] = []

    @Relationship(deleteRule: .cascade, inverse: \SDActivity.group)
    public var activities: [SDActivity] = []

    public init(
        id: String = UUID().uuidString,
        name: String,
        emoji: String = "👥",
        coverImageUrl: String? = nil,
        categoryRaw: String = GroupCategory.trip.rawValue,
        defaultCurrencyCode: String = "INR",
        createdByUserId: String,
        simplifyDebts: Bool = true,
        isArchived: Bool = false,
        members: [GroupMember] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.coverImageUrl = coverImageUrl
        self.categoryRaw = categoryRaw
        self.defaultCurrencyCode = defaultCurrencyCode
        self.createdByUserId = createdByUserId
        self.simplifyDebts = simplifyDebts
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(members), let jsonStr = String(data: data, encoding: .utf8) {
            self.membersJSON = jsonStr
        } else {
            self.membersJSON = "[]"
        }
    }

    public var members: [GroupMember] {
        get {
            guard let data = membersJSON.data(using: .utf8) else { return [] }
            let decoder = JSONDecoder()
            return (try? decoder.decode([GroupMember].self, from: data)) ?? []
        }
        set {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(newValue), let jsonStr = String(data: data, encoding: .utf8) {
                membersJSON = jsonStr
            }
        }
    }

    public var activeExpenses: [SDExpense] {
        expenses.filter { !$0.isDeleted }.sorted { $0.date > $1.date }
    }

    public var currency: Currency {
        Currency(rawValue: defaultCurrencyCode) ?? .inr
    }

    public var category: GroupCategory {
        GroupCategory(rawValue: categoryRaw) ?? .trip
    }
}
