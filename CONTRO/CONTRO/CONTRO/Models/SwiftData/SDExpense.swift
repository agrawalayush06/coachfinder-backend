//
//  SDExpense.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation
import SwiftData

public struct ExpensePayer: Codable, Identifiable, Hashable, Sendable {
    public var id: String { memberId }
    public var memberId: String
    public var amountMinorUnits: Int64

    public init(memberId: String, amountMinorUnits: Int64) {
        self.memberId = memberId
        self.amountMinorUnits = amountMinorUnits
    }
}

@Model
public final class SDExpense {
    @Attribute(.unique) public var id: String
    public var groupId: String
    public var title: String
    public var amountMinorUnits: Int64
    public var currencyCode: String
    public var categoryRaw: String
    public var date: Date
    public var notes: String
    public var receiptImageData: Data?
    public var payersJSON: String
    public var splitTypeRaw: String
    public var isRecurring: Bool
    public var createdByUserId: String
    public var createdAt: Date
    public var updatedAt: Date
    public var isDeleted: Bool
    public var deletedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \SDSplitItem.expense)
    public var splits: [SDSplitItem] = []

    public var group: SDGroup?

    public init(
        id: String = UUID().uuidString,
        groupId: String,
        title: String,
        amountMinorUnits: Int64,
        currencyCode: String = "INR",
        categoryRaw: String = ExpenseCategory.foodAndDining.rawValue,
        date: Date = Date(),
        notes: String = "",
        receiptImageData: Data? = nil,
        payers: [ExpensePayer] = [],
        splitTypeRaw: String = SplitType.equal.rawValue,
        isRecurring: Bool = false,
        createdByUserId: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isDeleted: Bool = false
    ) {
        self.id = id
        self.groupId = groupId
        self.title = title
        self.amountMinorUnits = amountMinorUnits
        self.currencyCode = currencyCode
        self.categoryRaw = categoryRaw
        self.date = date
        self.notes = notes
        self.receiptImageData = receiptImageData
        self.splitTypeRaw = splitTypeRaw
        self.isRecurring = isRecurring
        self.createdByUserId = createdByUserId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted

        let encoder = JSONEncoder()
        if let data = try? encoder.encode(payers), let jsonStr = String(data: data, encoding: .utf8) {
            self.payersJSON = jsonStr
        } else {
            self.payersJSON = "[]"
        }
    }

    public var payers: [ExpensePayer] {
        get {
            guard let data = payersJSON.data(using: .utf8) else { return [] }
            let decoder = JSONDecoder()
            return (try? decoder.decode([ExpensePayer].self, from: data)) ?? []
        }
        set {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(newValue), let jsonStr = String(data: data, encoding: .utf8) {
                payersJSON = jsonStr
            }
        }
    }

    public var category: ExpenseCategory {
        ExpenseCategory(rawValue: categoryRaw) ?? .foodAndDining
    }

    public var splitType: SplitType {
        SplitType(rawValue: splitTypeRaw) ?? .equal
    }

    public var currency: Currency {
        Currency(rawValue: currencyCode) ?? .inr
    }
}
