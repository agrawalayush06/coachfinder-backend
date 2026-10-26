//
//  AuthServiceProtocol.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

public struct UserSession: Codable, Sendable {
    public let uid: String
    public let phoneNumber: String
    public let displayName: String?

    public init(uid: String, phoneNumber: String, displayName: String? = nil) {
        self.uid = uid
        self.phoneNumber = phoneNumber
        self.displayName = displayName
    }
}

public protocol AuthServiceProtocol: Sendable {
    func sendVerificationCode(to phoneNumber: String) async throws -> String
    func verifyCode(_ code: String, verificationId: String) async throws -> UserSession
    func getCurrentUser() -> UserSession?
    func signOut() throws
}
