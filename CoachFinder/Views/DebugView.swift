import SwiftUI

struct DebugView: View {
    @State private var activities: [Activity] = []
    @State private var providers: [Provider] = []
    @State private var statusMessage: String = "Tap a button to test the backend API..."
    @State private var isLoading = false

    private let providerService: ProviderServiceProtocol = ProviderService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundColor(statusMessage.contains("Error") ? .red : .primary)
                    .multilineTextAlignment(.center)
                    .padding()

                if isLoading {
                    ProgressView("Connecting to Backend...")
                }

                HStack(spacing: 12) {
                    Button("Fetch Activities") {
                        Task {
                            await testActivities()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Fetch Providers") {
                        Task {
                            await testProviders()
                        }
                    }
                    .buttonStyle(.bordered)
                }

                List {
                    if !activities.isEmpty {
                        Section("Seeded Activities (\(activities.count))") {
                            ForEach(activities) { activity in
                                HStack {
                                    Text(activity.name)
                                        .bold()
                                    Spacer()
                                    Text(activity.category)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    if !providers.isEmpty {
                        Section("Providers (\(providers.count))") {
                            ForEach(providers) { provider in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(provider.name)
                                        .font(.headline)
                                    Text("\(provider.type) • \(provider.city)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Coach Finder Debug")
        }
    }

    @MainActor
    private func testActivities() async {
        isLoading = true
        statusMessage = "Fetching activities from \(AppConfig.baseURL)..."
        do {
            activities = try await providerService.fetchActivities()
            statusMessage = "Successfully fetched \(activities.count) activities!"
        } catch {
            statusMessage = "Error: \(error.localizedDescription)"
        }
        isLoading = false
    }

    @MainActor
    private func testProviders() async {
        isLoading = true
        statusMessage = "Fetching providers from \(AppConfig.baseURL)..."
        do {
            let response = try await providerService.fetchProviders(city: nil, activityId: nil, page: 0, size: 20)
            providers = response.content
            statusMessage = "Successfully fetched \(providers.count) providers!"
        } catch {
            statusMessage = "Error: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

#Preview {
    DebugView()
}
