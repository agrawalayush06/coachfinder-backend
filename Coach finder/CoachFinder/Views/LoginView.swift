import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue.gradient)
                            .padding(.top, 20)

                        Text("Welcome Back")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Sign in to your Coach Finder account")
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

                    // Form Fields
                    VStack(spacing: 16) {
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
                            SecureField("Password", text: $password)
                                .textContentType(.password)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Sign In Button
                    Button {
                        Task {
                            let success = await authManager.login(email: email, password: password)
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
                            Text(authManager.isLoading ? "Signing In..." : "Sign In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .blue.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                    .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                    .opacity(authManager.isLoading || email.isEmpty || password.isEmpty ? 0.6 : 1.0)

                    // Switch to Register
                    HStack {
                        Text("Don't have an account?")
                            .foregroundStyle(.secondary)
                        Button("Create One") {
                            showRegister = true
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
}
