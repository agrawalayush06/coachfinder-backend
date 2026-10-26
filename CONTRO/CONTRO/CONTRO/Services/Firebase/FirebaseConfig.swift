//
//  FirebaseConfig.swift
//  SplitEase
//
//  Created for SplitEase.
//

import Foundation

public final class FirebaseConfig: Sendable {
    public static let shared = FirebaseConfig()

    public var isCloudSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "splitease_cloud_sync_enabled") }
        set { UserDefaults.standard.set(newValue, forKey: "splitease_cloud_sync_enabled") }
    }

    public var projectId: String {
        if let custom = UserDefaults.standard.string(forKey: "splitease_firebase_project_id"), !custom.isEmpty {
            return custom
        }
        return readPlistValue(forKey: "PROJECT_ID") ?? "splitease-production-2026"
    }

    public var apiKey: String? {
        readPlistValue(forKey: "API_KEY")
    }

    public var storageBucket: String? {
        readPlistValue(forKey: "STORAGE_BUCKET")
    }

    public var bundleId: String? {
        readPlistValue(forKey: "BUNDLE_ID")
    }

    public var googleAppId: String? {
        readPlistValue(forKey: "GOOGLE_APP_ID")
    }

    public var gcmSenderId: String? {
        readPlistValue(forKey: "GCM_SENDER_ID")
    }

    public var isConfiguredFromPlist: Bool {
        readPlistValue(forKey: "PROJECT_ID") != nil
    }

    public func readPlistValue(forKey key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
            return nil
        }
        return dict[key] as? String
    }
}
