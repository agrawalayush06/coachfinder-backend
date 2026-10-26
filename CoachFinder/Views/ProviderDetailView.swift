import SwiftUI
import MapKit

/// Screen displaying the details of a specific Coach or Academy.
struct ProviderDetailView: View {
    @State private var viewModel: ProviderDetailViewModel

    @Environment(AuthManager.self) private var authManager: AuthManager?
    @State private var showingBookSheet: Bool = false
    @State private var showingLoginAlert: Bool = false

    init(provider: Provider) {
        _viewModel = State(initialValue: ProviderDetailViewModel(providerId: provider.id, initialProvider: provider))
    }

    init(providerId: Int) {
        _viewModel = State(initialValue: ProviderDetailViewModel(providerId: providerId))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.provider == nil {
                ProgressView("Loading details...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage, viewModel.provider == nil {
                ContentUnavailableView {
                    Label("Error Loading Provider", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                } actions: {
                    Button("Try Again") {
                        Task {
                            await viewModel.loadDetails()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if let provider = viewModel.provider {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header Card
                        headerCard(provider: provider)

                        // Location Section
                        locationSection(provider: provider)

                        // General Information Section
                        infoSection(provider: provider)
                    }
                    .padding()
                    .padding(.bottom, 20)
                }
                .safeAreaInset(edge: .bottom) {
                    bottomActionBar(provider: provider)
                }
                .refreshable {
                    await viewModel.loadDetails()
                }
            }
        }
        .navigationTitle(viewModel.provider?.name ?? "Provider Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingBookSheet) {
            if let provider = viewModel.provider {
                BookSessionSheet(provider: provider)
            }
        }
        .alert("Sign In Required", isPresented: $showingLoginAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please sign in or create an account from the Profile tab to book a session.")
        }
        .task {
            await viewModel.loadDetails()
        }
    }

    // MARK: - Bottom Action Bar
    private func bottomActionBar(provider: Provider) -> some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Button {
                    if authManager?.isAuthenticated == true {
                        showingBookSheet = true
                    } else {
                        showingLoginAlert = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.headline)
                        Text("Book a Session")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial)
        }
    }

    // MARK: - Header Card
    private func headerCard(provider: Provider) -> some View {
        let isCoach = provider.type.uppercased() == "COACH"

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(provider.type.uppercased())
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(isCoach ? Color.blue.opacity(0.15) : Color.orange.opacity(0.15))
                    )
                    .foregroundStyle(isCoach ? Color.blue : Color.orange)

                Spacer()

                Text("ID #\(provider.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(provider.name)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    // MARK: - Location Section
    private func locationSection(provider: Provider) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Location", systemImage: "mappin.and.ellipse")
                .font(.headline)

            HStack {
                Text("City")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(provider.city)
                    .fontWeight(.medium)
            }
            .font(.subheadline)

            if let distance = provider.formattedDistance {
                HStack {
                    Text("Distance")
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(distance)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.blue)
                }
                .font(.subheadline)
            }

            if let lat = provider.lat, let lng = provider.lng, let coordinate = provider.coordinate {
                HStack {
                    Text("Coordinates")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.4f, %.4f", lat, lng))
                        .fontWeight(.medium)
                        .font(.system(.subheadline, design: .monospaced))
                }

                // Interactive Mini Map
                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )) {
                    Marker(provider.name, coordinate: coordinate)
                        .tint(provider.type.uppercased() == "COACH" ? .blue : .orange)
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
            } else {
                Text("No GPS coordinates provided for this venue.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    // MARK: - Information Section
    private func infoSection(provider: Provider) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Details", systemImage: "info.circle")
                .font(.headline)

            DetailRow(title: "Owner User ID", value: "#\(provider.userId)")

            if let createdAt = provider.createdAt {
                DetailRow(title: "Created", value: formatDate(createdAt))
            }

            if let updatedAt = provider.updatedAt {
                DetailRow(title: "Updated", value: formatDate(updatedAt))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func formatDate(_ isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return isoString
    }
}

private struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
