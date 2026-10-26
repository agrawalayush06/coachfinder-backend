//
//  SDUser.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation
import SwiftData

@Model
public final class SDUser {
    @Attribute(.unique) public var id: String
    public var phoneNumber: String
    public var name: String
    public var avatarUrl: String?
    public var defaultCurrencyCode: String
    public var upiId: String?
    public var isCurrentUser: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: String = UUID().uuidString,
        phoneNumber: String,
        name: String,
        avatarUrl: String? = nil,
        defaultCurrencyCode: String = "INR",
        upiId: String? = nil,
        isCurrentUser: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.phoneNumber = phoneNumber
        self.name = name
        self.avatarUrl = avatarUrl
        self.defaultCurrencyCode = defaultCurrencyCode
        self.upiId = upiId
        self.isCurrentUser = isCurrentUser
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var currency: Currency {
        Currency(rawValue: defaultCurrencyCode) ?? .inr
    }

    public var initials: String {
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
}
