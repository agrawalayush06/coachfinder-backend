import SwiftUI

@main
struct CoachFinderApp: App {
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(authManager)
                .task {
                    await authManager.checkAuthStatus()
                }
        }
    }
}
