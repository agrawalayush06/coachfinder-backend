import Foundation

public protocol AuthServiceProtocol: Sendable {
    func register(_ request: RegisterRequest) async throws -> AuthResponse
    func login(_ request: LoginRequest) async throws -> AuthResponse
    func getMe() async throws -> User
}

public final class AuthService: AuthServiceProtocol, Sendable {
    private let apiClient: APIClient

    public init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    public func register(_ request: RegisterRequest) async throws -> AuthResponse {
        try await apiClient.request("v1/auth/register", method: "POST", body: request)
    }

    public func login(_ request: LoginRequest) async throws -> AuthResponse {
        try await apiClient.request("v1/auth/login", method: "POST", body: request)
    }

    public func getMe() async throws -> User {
        try await apiClient.request("v1/auth/me", method: "GET")
    }
}
