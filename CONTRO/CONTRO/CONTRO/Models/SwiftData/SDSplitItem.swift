//
//  SDSplitItem.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation
import SwiftData

@Model
public final class SDSplitItem {
    @Attribute(.unique) public var id: String
    public var participantId: String
    public var participantName: String
    public var amountMinorUnits: Int64
    public var percentage: Double
    public var shareCount: Int
    public var detail: String?

    public var expense: SDExpense?

    public init(
        id: String = UUID().uuidString,
        participantId: String,
        participantName: String,
        amountMinorUnits: Int64,
        percentage: Double = 0.0,
        shareCount: Int = 1,
        detail: String? = nil
    ) {
        self.id = id
        self.participantId = participantId
        self.participantName = participantName
        self.amountMinorUnits = amountMinorUnits
        self.percentage = percentage
        self.shareCount = shareCount
        self.detail = detail
    }
}
