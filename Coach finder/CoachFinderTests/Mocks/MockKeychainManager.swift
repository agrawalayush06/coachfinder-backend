import Foundation
import CoachFinderCore

final class MockKeychainManager: KeychainManagerProtocol, @unchecked Sendable {
    private var tokenStorage: String?

    init(initialToken: String? = nil) {
        self.tokenStorage = initialToken
    }

    func saveToken(_ token: String) -> Bool {
        tokenStorage = token
        return true
    }

    func getToken() -> String? {
        return tokenStorage
    }

    func deleteToken() -> Bool {
        tokenStorage = nil
        return true
    }
}
