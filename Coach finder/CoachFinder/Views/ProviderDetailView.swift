import SwiftUI
import MapKit

/// Screen displaying the details of a specific Coach or Academy.
struct ProviderDetailView: View {
    @State private var viewModel: ProviderDetailViewModel

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
                }
                .refreshable {
                    await viewModel.loadDetails()
                }
            }
        }
        .navigationTitle(viewModel.provider?.name ?? "Provider Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDetails()
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

#Preview {
    NavigationStack {
        ProviderDetailView(
            provider: Provider(
                id: 1,
                userId: 1,
                type: "COACH",
                name: "Elite Cricket Academy",
                city: "London",
                lat: 51.5074,
                lng: -0.1278,
                createdAt: "2026-10-01T10:00:00Z",
                updatedAt: "2026-10-01T10:00:00Z"
            )
        )
    }
}
