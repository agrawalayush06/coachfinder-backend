import SwiftUI

struct ProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var showLoginSheet = false
    @State private var showRegisterSheet = false
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if let user = authManager.currentUser {
                    authenticatedContent(user: user)
                } else {
                    unauthenticatedContent
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
            .sheet(isPresented: $showRegisterSheet) {
                RegisterView()
            }
            .confirmationDialog("Are you sure you want to sign out?", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {
                    authManager.logout()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Authenticated View
    @ViewBuilder
    private func authenticatedContent(user: User) -> some View {
        VStack(spacing: 24) {
            // Profile Card Header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(roleGradient(for: user.role))
                        .frame(width: 84, height: 84)
                        .shadow(color: roleColor(for: user.role).opacity(0.3), radius: 8, x: 0, y: 4)

                    Text(initials(for: user.name))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }

                VStack(spacing: 4) {
                    Text(user.name)
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(user.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Role Pill Badge
                HStack(spacing: 6) {
                    Image(systemName: user.role.uppercased() == "COACH" ? "figure.run.circle.fill" : "graduationcap.fill")
                        .font(.footnote)
                    Text(user.role.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(roleColor(for: user.role).opacity(0.12))
                .foregroundStyle(roleColor(for: user.role))
                .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Details Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Account Details")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 4)

                VStack(spacing: 0) {
                    detailRow(title: "Account ID", value: "#\(user.id)", icon: "number")
                    Divider().padding(.leading, 44)
                    detailRow(title: "Role", value: user.role.capitalized, icon: "person.badge.shield.checkmark")
                    if let createdAt = user.createdAt {
                        Divider().padding(.leading, 44)
                        detailRow(title: "Member Since", value: String(createdAt.prefix(10)), icon: "calendar")
                    }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // Quick Actions / Features
            VStack(alignment: .leading, spacing: 12) {
                Text("Features")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 4)

                VStack(spacing: 0) {
                    NavigationLink {
                        MyBookingsView()
                    } label: {
                        featureRow(title: "My Booked Sessions", icon: "calendar.badge.clock", color: .blue)
                    }

                    if user.role.uppercased() == "COACH" {
                        Divider().padding(.leading, 44)
                        featureRow(title: "Manage Coaching Profile", icon: "briefcase.fill", color: .indigo)
                        Divider().padding(.leading, 44)
                        featureRow(title: "Offered Activities", icon: "figure.tennis", color: .teal)
                    } else {
                        Divider().padding(.leading, 44)
                        featureRow(title: "Favorite Coaches", icon: "heart.fill", color: .pink)
                    }
                    Divider().padding(.leading, 44)
                    featureRow(title: "Help & Support", icon: "questionmark.circle.fill", color: .green)
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // Sign Out Button
            Button(role: .destructive) {
                showLogoutConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
        .padding(16)
    }

    // MARK: - Unauthenticated View
    @ViewBuilder
    private var unauthenticatedContent: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.1))
                        .frame(width: 96, height: 96)

                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue.gradient)
                }

                VStack(spacing: 8) {
                    Text("Welcome to Coach Finder")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Sign in to book sessions, discover certified coaches, and save your favorite training academies.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }

            VStack(spacing: 12) {
                Button {
                    showLoginSheet = true
                } label: {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .blue.opacity(0.25), radius: 8, x: 0, y: 4)
                }

                Button {
                    showRegisterSheet = true
                } label: {
                    Text("Create New Account")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .padding(24)
    }

    // MARK: - Helpers
    private func detailRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .padding(14)
    }

    private func featureRow(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 20)
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ").prefix(2)
        if parts.isEmpty { return "U" }
        return parts.map { String($0.prefix(1)) }.joined().uppercased()
    }

    private func roleColor(for role: String) -> Color {
        switch role.uppercased() {
        case "COACH": return .indigo
        case "STUDENT": return .blue
        case "ADMIN": return .orange
        default: return .secondary
        }
    }

    private func roleGradient(for role: String) -> LinearGradient {
        let base = roleColor(for: role)
        return LinearGradient(
            colors: [base, base.opacity(0.75)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview("Logged In") {
    let manager = AuthManager()
    manager.currentUser = User(id: 1, email: "alex@example.com", name: "Alex Ferguson", role: "COACH", createdAt: "2026-10-26")
    return ProfileView()
        .environment(manager)
}

#Preview("Logged Out") {
    ProfileView()
        .environment(AuthManager())
}
