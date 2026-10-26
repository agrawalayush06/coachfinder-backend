//
//  SDSettlement.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation
import SwiftData

@Model
public final class SDSettlement {
    @Attribute(.unique) public var id: String
    public var groupId: String
    public var payerId: String
    public var payerName: String
    public var receiverId: String
    public var receiverName: String
    public var amountMinorUnits: Int64
    public var currencyCode: String
    public var methodRaw: String
    public var statusRaw: String
    public var upiTransactionRef: String?
    public var timestamp: Date

    public var group: SDGroup?

    public init(
        id: String = UUID().uuidString,
        groupId: String,
        payerId: String,
        payerName: String,
        receiverId: String,
        receiverName: String,
        amountMinorUnits: Int64,
        currencyCode: String = "INR",
        methodRaw: String = SettlementMethod.upi.rawValue,
        statusRaw: String = SettlementStatus.confirmed.rawValue,
        upiTransactionRef: String? = nil,
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
        self.upiTransactionRef = upiTransactionRef
        self.timestamp = timestamp
    }

    public var method: SettlementMethod {
        SettlementMethod(rawValue: methodRaw) ?? .upi
    }

    public var status: SettlementStatus {
        SettlementStatus(rawValue: statusRaw) ?? .confirmed
    }

    public var currency: Currency {
        Currency(rawValue: currencyCode) ?? .inr
    }
}
