//
//  DataRefreshCoordinator.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

extension Notification.Name {
    public static let appDataDidChange = Notification.Name("splitease_appDataDidChange")
}

public struct DataRefreshCoordinator {
    @MainActor
    public static func notifyDataChanged() {
        NotificationCenter.default.post(name: .appDataDidChange, object: nil)
    }
}
