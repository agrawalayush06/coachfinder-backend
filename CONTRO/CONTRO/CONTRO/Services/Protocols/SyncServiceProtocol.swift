//
//  SyncServiceProtocol.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

public enum SyncStatus: String, Sendable {
    case synced = "Synced"
    case syncing = "Syncing..."
    case offline = "Offline Mode"
    case error = "Sync Error"
}

public protocol SyncServiceProtocol: Sendable {
    func uploadUser(dto: UserDTO) async throws
    func uploadGroup(dto: GroupDTO) async throws
    func uploadExpense(dto: ExpenseDTO) async throws
    func uploadSettlement(dto: SettlementDTO) async throws

    func fetchRemoteGroups(for userId: String) async throws -> [GroupDTO]
    func fetchRemoteExpenses(for groupId: String) async throws -> [ExpenseDTO]
    func fetchRemoteSettlements(for groupId: String) async throws -> [SettlementDTO]
}
