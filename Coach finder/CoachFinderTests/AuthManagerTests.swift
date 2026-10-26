import Testing
#if canImport(CoachFinderCore)
@testable import CoachFinderCore
#elseif canImport(Coach_finder)
@testable import Coach_finder
#endif

@Suite("AuthManager Tests")
@MainActor
struct AuthManagerTests {

    private func makeSUT(
        initialToken: String? = nil,
        mockService: MockAuthService = MockAuthService()
    ) -> (AuthManager, MockKeychainManager, MockAuthService) {
        let mockKeychain = MockKeychainManager(initialToken: initialToken)
        let manager = AuthManager(authService: mockService, keychainManager: mockKeychain)
        return (manager, mockKeychain, mockService)
    }

    @Test
    func login_Success_UpdatesCurrentUserAndSavesToken() async {
        let (manager, keychain, _) = makeSUT()

        let success = await manager.login(email: "coach@test.com", password: "password123")

        #expect(success == true)
        #expect(manager.isAuthenticated == true)
        #expect(manager.currentUser?.email == "coach@test.com")
        #expect(keychain.getToken() == "mock-token")
        #expect(manager.errorMessage == nil)
    }

    @Test
    func login_Failure_SetsErrorMessageAndKeepsCurrentUserNil() async {
        let mockService = MockAuthService()
        mockService.loginResult = .failure(APIError.serverError(message: "Invalid email or password"))
        let (manager, keychain, _) = makeSUT(mockService: mockService)

        let success = await manager.login(email: "wrong@test.com", password: "bad")

        #expect(success == false)
        #expect(manager.isAuthenticated == false)
        #expect(manager.currentUser == nil)
        #expect(keychain.getToken() == nil)
        #expect(manager.errorMessage == "Invalid email or password")
    }

    @Test
    func login_EmptyFields_RejectsWithoutCallingService() async {
        let (manager, _, _) = makeSUT()

        let success = await manager.login(email: "", password: "")

        #expect(success == false)
        #expect(manager.errorMessage != nil)
    }

    @Test
    func register_Success_UpdatesCurrentUserAndSavesToken() async {
        let (manager, keychain, _) = makeSUT()

        let success = await manager.register(
            email: "student@test.com",
            password: "securePassword",
            name: "Alice Student",
            role: "STUDENT"
        )

        #expect(success == true)
        #expect(manager.isAuthenticated == true)
        #expect(manager.currentUser?.email == "student@test.com")
        #expect(manager.currentUser?.name == "Alice Student")
        #expect(keychain.getToken() == "mock-token")
        #expect(manager.errorMessage == nil)
    }

    @Test
    func register_ShortPassword_RejectsImmediately() async {
        let (manager, _, _) = makeSUT()

        let success = await manager.register(
            email: "student@test.com",
            password: "123",
            name: "Alice",
            role: "STUDENT"
        )

        #expect(success == false)
        #expect(manager.errorMessage == "Password must be at least 6 characters.")
    }

    @Test
    func logout_ClearsTokenAndCurrentUser() async {
        let (manager, keychain, _) = makeSUT(initialToken: "existing-token")
        manager.currentUser = User(id: 1, email: "user@test.com", name: "User", role: "USER")

        manager.logout()

        #expect(manager.isAuthenticated == false)
        #expect(manager.currentUser == nil)
        #expect(keychain.getToken() == nil)
        #expect(manager.errorMessage == nil)
    }

    @Test
    func checkAuthStatus_WithToken_FetchesCurrentUser() async {
        let (manager, _, _) = makeSUT(initialToken: "valid-token")

        await manager.checkAuthStatus()

        #expect(manager.isAuthenticated == true)
        #expect(manager.currentUser?.email == "test@example.com")
    }

    @Test
    func checkAuthStatus_WithoutToken_LeavesCurrentUserNil() async {
        let (manager, _, _) = makeSUT(initialToken: nil)

        await manager.checkAuthStatus()

        #expect(manager.isAuthenticated == false)
        #expect(manager.currentUser == nil)
    }

    @Test
    func checkAuthStatus_WhenServiceFails_DeletesTokenAndResetsCurrentUser() async {
        let mockService = MockAuthService()
        mockService.getMeResult = .failure(APIError.serverError(message: "Unauthorized"))
        let (manager, keychain, _) = makeSUT(initialToken: "invalid-token", mockService: mockService)

        await manager.checkAuthStatus()

        #expect(manager.isAuthenticated == false)
        #expect(manager.currentUser == nil)
        #expect(keychain.getToken() == nil)
    }
}
