import SwiftUI
import MapKit

/// Full-screen interactive map displaying pins for coaches and academies with GPS coordinates.
struct ProviderMapView: View {
    @State var viewModel: ProviderMapViewModel
    var sharedProviders: [Provider]?
    @State private var navigationProvider: Provider? = nil

    init(
        viewModel: ProviderMapViewModel? = nil,
        sharedProviders: [Provider]? = nil
    ) {
        self._viewModel = State(initialValue: viewModel ?? ProviderMapViewModel())
        self.sharedProviders = sharedProviders
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Interactive Map
                Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedProviderId) {
                    // Show User Location if authorized
                    UserAnnotation()

                    // Provider Pins
                    ForEach(viewModel.providersWithCoordinates) { provider in
                        if let coordinate = provider.coordinate {
                            Marker(provider.name, coordinate: coordinate)
                                .tint(provider.type.uppercased() == "COACH" ? .blue : .orange)
                                .tag(provider.id)
                        }
                    }
                }
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }

                // Selected Provider Preview Card (at bottom)
                if let selected = viewModel.selectedProvider {
                    selectedProviderCard(provider: selected)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding()
                }

                // Top/Side Controls Overlay (Center on User Button, Loading Indicator)
                VStack {
                    HStack {
                        Spacer()

                        // "Center on Me" Floating Button
                        Button {
                            viewModel.centerOnUser()
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.title3)
                                .foregroundStyle(Color.accentColor)
                                .padding(12)
                                .background(.ultraThinMaterial, in: Circle())
                                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                    }

                    Spacer()
                }

                // Loading Overlay
                if viewModel.isLoading && viewModel.providers.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Loading map markers...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }

                // Error Banner Overlay
                if let error = viewModel.errorMessage {
                    VStack {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.primary)
                            Spacer()
                            Button("Dismiss") {
                                viewModel.errorMessage = nil
                            }
                            .font(.footnote.weight(.semibold))
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .padding()

                        Spacer()
                    }
                }
            }
            .navigationTitle("Provider Map")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $navigationProvider) { provider in
                ProviderDetailView(provider: provider)
            }
            .task {
                if let shared = sharedProviders, !shared.isEmpty {
                    viewModel.setProviders(shared)
                } else {
                    await viewModel.loadProviders()
                }
            }
            .onChange(of: sharedProviders) { _, newProviders in
                if let newProviders, !newProviders.isEmpty {
                    viewModel.setProviders(newProviders)
                }
            }
            .onChange(of: viewModel.locationManager.userLocation != nil) { _, hasLocation in
                // If user location becomes available after request, center on it
                if hasLocation && viewModel.locationManager.isLocating {
                    viewModel.centerOnUser()
                }
            }
        }
    }

    // MARK: - Selected Provider Floating Card
    private func selectedProviderCard(provider: Provider) -> some View {
        let isCoach = provider.type.uppercased() == "COACH"

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(provider.type.uppercased())
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(isCoach ? Color.blue.opacity(0.15) : Color.orange.opacity(0.15))
                        )
                        .foregroundStyle(isCoach ? Color.blue : Color.orange)

                    Text(provider.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(provider.city)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if let distance = provider.formattedDistance {
                            Text("•")
                                .foregroundStyle(.secondary)
                            HStack(spacing: 3) {
                                Image(systemName: "location.fill")
                                    .font(.caption2)
                                Text(distance)
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundStyle(Color.accentColor)
                        }
                    }
                }

                Spacer()

                Button {
                    withAnimation {
                        viewModel.selectedProviderId = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            // View Details Button
            Button {
                navigationProvider = provider
            } label: {
                HStack {
                    Text("View Full Details")
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
        )
    }
}

#Preview {
    ProviderMapView()
}
