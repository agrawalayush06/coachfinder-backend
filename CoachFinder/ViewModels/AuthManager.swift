import Foundation
import Observation

@Observable
@MainActor
public final class AuthManager {
    public var currentUser: User?
    public var isLoading: Bool = false
    public var errorMessage: String?

    public var isAuthenticated: Bool {
        currentUser != nil
    }

    private let authService: any AuthServiceProtocol
    private let keychainManager: any KeychainManagerProtocol

    public init(
        authService: any AuthServiceProtocol = AuthService(),
        keychainManager: any KeychainManagerProtocol = KeychainManager.shared
    ) {
        self.authService = authService
        self.keychainManager = keychainManager
    }

    public func checkAuthStatus() async {
        guard keychainManager.getToken() != nil else {
            currentUser = nil
            return
        }

        isLoading = true
        errorMessage = nil
        do {
            currentUser = try await authService.getMe()
        } catch {
            keychainManager.deleteToken()
            currentUser = nil
        }
        isLoading = false
    }

    @discardableResult
    public func login(email: String, password: String) async -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = LoginRequest(email: trimmedEmail, password: password)
            let response = try await authService.login(request)
            keychainManager.saveToken(response.token)
            currentUser = response.user
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    @discardableResult
    public func register(email: String, password: String, name: String, role: String) async -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !password.isEmpty, !trimmedName.isEmpty else {
            errorMessage = "Please fill in all required fields."
            return false
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = RegisterRequest(email: trimmedEmail, password: password, name: trimmedName, role: role)
            let response = try await authService.register(request)
            keychainManager.saveToken(response.token)
            currentUser = response.user
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    public func logout() {
        keychainManager.deleteToken()
        currentUser = nil
        errorMessage = nil
    }
}
