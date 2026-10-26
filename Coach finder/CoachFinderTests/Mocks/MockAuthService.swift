import Foundation
import CoachFinderCore

final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {
    var registerResult: Result<AuthResponse, Error>?
    var loginResult: Result<AuthResponse, Error>?
    var getMeResult: Result<User, Error>?

    func register(_ request: RegisterRequest) async throws -> AuthResponse {
        if let result = registerResult {
            return try result.get()
        }
        return AuthResponse(token: "mock-token", user: User(id: 1, email: request.email, name: request.name, role: request.role))
    }

    func login(_ request: LoginRequest) async throws -> AuthResponse {
        if let result = loginResult {
            return try result.get()
        }
        return AuthResponse(token: "mock-token", user: User(id: 1, email: request.email, name: "Test User", role: "STUDENT"))
    }

    func getMe() async throws -> User {
        if let result = getMeResult {
            return try result.get()
        }
        return User(id: 1, email: "test@example.com", name: "Test User", role: "STUDENT")
    }
}
