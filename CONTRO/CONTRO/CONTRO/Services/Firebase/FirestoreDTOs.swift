//
//  FirestoreDTOs.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

public struct UserDTO: Codable, Sendable {
    public let id: String
    public let phoneNumber: String
    public let name: String
    public let upiId: String?
    public let currencyCode: String
    public let updatedAt: Date

    public init(id: String, phoneNumber: String, name: String, upiId: String? = nil, currencyCode: String = "INR", updatedAt: Date = Date()) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.name = name
        self.upiId = upiId
        self.currencyCode = currencyCode
        self.updatedAt = updatedAt
    }
}

public struct GroupMemberDTO: Codable, Sendable {
    public let id: String
    public let name: String
    public let phoneNumber: String
    public let role: String
    public let isPending: Bool
    public let upiId: String?

    public init(id: String, name: String, phoneNumber: String, role: String, isPending: Bool, upiId: String? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.role = role
        self.isPending = isPending
        self.upiId = upiId
    }
}

public struct GroupDTO: Codable, Sendable {
    public let id: String
    public let name: String
    public let emoji: String
    public let categoryRaw: String
    public let defaultCurrencyCode: String
    public let createdByUserId: String
    public let simplifyDebts: Bool
    public let isArchived: Bool
    public let members: [GroupMemberDTO]
    public let memberIds: [String]
    public let updatedAt: Date

    public init(
        id: String,
        name: String,
        emoji: String,
        categoryRaw: String,
        defaultCurrencyCode: String,
        createdByUserId: String,
        simplifyDebts: Bool,
        isArchived: Bool,
        members: [GroupMemberDTO],
        memberIds: [String],
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.categoryRaw = categoryRaw
        self.defaultCurrencyCode = defaultCurrencyCode
        self.createdByUserId = createdByUserId
        self.simplifyDebts = simplifyDebts
        self.isArchived = isArchived
        self.members = members
        self.memberIds = memberIds
        self.updatedAt = updatedAt
    }
}

public struct ExpensePayerDTO: Codable, Sendable {
    public let memberId: String
    public let amountMinorUnits: Int64

    public init(memberId: String, amountMinorUnits: Int64) {
        self.memberId = memberId
        self.amountMinorUnits = amountMinorUnits
    }
}

public struct SplitItemDTO: Codable, Sendable {
    public let participantId: String
    public let participantName: String
    public let amountMinorUnits: Int64
    public let percentage: Double
    public let detail: String?

    public init(participantId: String, participantName: String, amountMinorUnits: Int64, percentage: Double = 0.0, detail: String? = nil) {
        self.participantId = participantId
        self.participantName = participantName
        self.amountMinorUnits = amountMinorUnits
        self.percentage = percentage
        self.detail = detail
    }
}

public struct ExpenseDTO: Codable, Sendable {
    public let id: String
    public let groupId: String
    public let title: String
    public let amountMinorUnits: Int64
    public let currencyCode: String
    public let categoryRaw: String
    public let date: Date
    public let notes: String
    public let payers: [ExpensePayerDTO]
    public let splits: [SplitItemDTO]
    public let splitTypeRaw: String
    public let isRecurring: Bool
    public let createdByUserId: String
    public let isDeleted: Bool
    public let updatedAt: Date

    public init(
        id: String,
        groupId: String,
        title: String,
        amountMinorUnits: Int64,
        currencyCode: String,
        categoryRaw: String,
        date: Date,
        notes: String,
        payers: [ExpensePayerDTO],
        splits: [SplitItemDTO],
        splitTypeRaw: String,
        isRecurring: Bool,
        createdByUserId: String,
        isDeleted: Bool,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.groupId = groupId
        self.title = title
        self.amountMinorUnits = amountMinorUnits
        self.currencyCode = currencyCode
        self.categoryRaw = categoryRaw
        self.date = date
        self.notes = notes
        self.payers = payers
        self.splits = splits
        self.splitTypeRaw = splitTypeRaw
        self.isRecurring = isRecurring
        self.createdByUserId = createdByUserId
        self.isDeleted = isDeleted
        self.updatedAt = updatedAt
    }
}

public struct SettlementDTO: Codable, Sendable {
    public let id: String
    public let groupId: String
    public let payerId: String
    public let payerName: String
    public let receiverId: String
    public let receiverName: String
    public let amountMinorUnits: Int64
    public let currencyCode: String
    public let methodRaw: String
    public let statusRaw: String
    public let timestamp: Date

    public init(
        id: String,
        groupId: String,
        payerId: String,
        payerName: String,
        receiverId: String,
        receiverName: String,
        amountMinorUnits: Int64,
        currencyCode: String,
        methodRaw: String,
        statusRaw: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.groupId = groupId
        self.payerId = payerId
        self.payerName = payerName
        self.receiverId = receiverId
        self.receiverName = receiverName
        self.amountMinorUnits = amountMinorUnits
        self.currencyCode = currencyCode
        self.methodRaw = methodRaw
        self.statusRaw = statusRaw
        self.timestamp = timestamp
    }
}
