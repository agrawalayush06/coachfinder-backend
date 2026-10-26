import SwiftUI

struct RegisterView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var role = "STUDENT"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue.gradient)
                            .padding(.top, 10)

                        Text("Create Account")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Join Coach Finder today")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Error Banner
                    if let errorMessage = authManager.errorMessage {
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.red)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // Role Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("I want to join as:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        Picker("Role", selection: $role) {
                            Text("Student / Learner").tag("STUDENT")
                            Text("Coach / Academy").tag("COACH")
                        }
                        .pickerStyle(.segmented)
                    }

                    // Form Fields
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            TextField("Full Name", text: $name)
                                .textContentType(.name)
                                .autocorrectionDisabled()
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            TextField("Email Address", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            SecureField("Password (min 6 chars)", text: $password)
                                .textContentType(.newPassword)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Create Account Button
                    Button {
                        Task {
                            let success = await authManager.register(
                                email: email,
                                password: password,
                                name: name,
                                role: role
                            )
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            if authManager.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 6)
                            }
                            Text(authManager.isLoading ? "Creating Account..." : "Create Account")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .blue.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                    .disabled(authManager.isLoading || name.isEmpty || email.isEmpty || password.count < 6)
                    .opacity(authManager.isLoading || name.isEmpty || email.isEmpty || password.count < 6 ? 0.6 : 1.0)
                }
                .padding(24)
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RegisterView()
        .environment(AuthManager())
}
