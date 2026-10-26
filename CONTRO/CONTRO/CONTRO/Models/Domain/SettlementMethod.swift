//
//  SettlementMethod.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI

public enum SettlementMethod: String, CaseIterable, Codable, Identifiable, Sendable {
    case upi = "upi"
    case cash = "cash"
    case bankTransfer = "bank_transfer"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .upi: return "UPI (PhonePe, GPay, Paytm)"
        case .cash: return "Cash Payment"
        case .bankTransfer: return "Bank Transfer (NEFT/IMPS)"
        }
    }

    public var systemImage: String {
        switch self {
        case .upi: return "qrcode"
        case .cash: return "banknote.fill"
        case .bankTransfer: return "building.columns.fill"
        }
    }
}

public enum SettlementStatus: String, CaseIterable, Codable, Sendable {
    case pending = "pending"
    case confirmed = "confirmed"
    case rejected = "rejected"

    public var title: String {
        switch self {
        case .pending: return "Pending Confirmation"
        case .confirmed: return "Settled"
        case .rejected: return "Rejected"
        }
    }

    public var color: Color {
        switch self {
        case .pending: return .orange
        case .confirmed: return .green
        case .rejected: return .red
        }
    }
}
