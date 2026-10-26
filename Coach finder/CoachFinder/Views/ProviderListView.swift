import SwiftUI

/// Main Provider List screen with city search, activity filter pills, radius/type filters, pagination, and pull-to-refresh.
struct ProviderListView: View {
    @Bindable var viewModel: ProviderListViewModel

    init(viewModel: ProviderListViewModel? = nil) {
        self.viewModel = viewModel ?? ProviderListViewModel()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Horizontal Activity Filter Pills
                if !viewModel.activities.isEmpty {
                    ActivityFilterPillsView(
                        activities: viewModel.activities,
                        selectedActivity: viewModel.selectedActivity
                    ) { activity in
                        Task {
                            await viewModel.selectActivity(activity)
                        }
                    }
                    Divider()
                }

                // Secondary Filter Bar (Radius, Type, Sort)
                filterBarView
                Divider()

                // Main Content Area
                contentView
            }
            .navigationTitle("Coach Finder")
            .navigationDestination(for: Provider.self) { provider in
                ProviderDetailView(provider: provider)
            }
            .searchable(
                text: $viewModel.citySearchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search by city (e.g. Mumbai, Bangalore)"
            )
            .onSubmit(of: .search) {
                Task {
                    await viewModel.searchCity()
                }
            }
            .onChange(of: viewModel.citySearchQuery) { oldValue, newValue in
                // Automatically reset list if user clears the search query
                if newValue.isEmpty && !oldValue.isEmpty {
                    Task {
                        await viewModel.searchCity()
                    }
                }
            }
            .task {
                await viewModel.loadInitialData()
            }
        }
    }

    // MARK: - Secondary Filter Bar (Radius, Type, Sort)
    private var filterBarView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Radius Menu
                Menu {
                    Button("Any Distance") {
                        Task { await viewModel.selectRadius(nil) }
                    }
                    Button("Within 5 km") {
                        Task { await viewModel.selectRadius(5.0) }
                    }
                    Button("Within 10 km") {
                        Task { await viewModel.selectRadius(10.0) }
                    }
                    Button("Within 25 km") {
                        Task { await viewModel.selectRadius(25.0) }
                    }
                    Button("Within 50 km") {
                        Task { await viewModel.selectRadius(50.0) }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "location.circle")
                        Text(viewModel.selectedRadiusKm == nil ? "Radius: Any" : "Within \(Int(viewModel.selectedRadiusKm!))km")
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(viewModel.selectedRadiusKm != nil ? Color.blue.opacity(0.15) : Color(.tertiarySystemFill))
                    .foregroundStyle(viewModel.selectedRadiusKm != nil ? Color.blue : Color.primary)
                    .clipShape(Capsule())
                }

                // Type Menu
                Menu {
                    Button("All Types") {
                        Task { await viewModel.selectType(nil) }
                    }
                    Button("Individual Coaches") {
                        Task { await viewModel.selectType("INDIVIDUAL") }
                    }
                    Button("Academies") {
                        Task { await viewModel.selectType("ACADEMY") }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                        Text(viewModel.selectedType == nil ? "All Types" : (viewModel.selectedType == "INDIVIDUAL" ? "Coaches" : "Academies"))
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(viewModel.selectedType != nil ? Color.orange.opacity(0.15) : Color(.tertiarySystemFill))
                    .foregroundStyle(viewModel.selectedType != nil ? Color.orange : Color.primary)
                    .clipShape(Capsule())
                }

                // Sort Menu
                Menu {
                    Button("Nearest First") {
                        Task { await viewModel.selectSortBy("distance") }
                    }
                    Button("Alphabetical (A-Z)") {
                        Task { await viewModel.selectSortBy("name") }
                    }
                    Button("Newest Added") {
                        Task { await viewModel.selectSortBy("createdAt") }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(viewModel.selectedSortBy == "distance" ? "Nearest" : (viewModel.selectedSortBy == "name" ? "Name" : "Newest"))
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemFill))
                    .foregroundStyle(.primary)
                    .clipShape(Capsule())
                }

                if viewModel.selectedRadiusKm != nil || viewModel.selectedType != nil {
                    Button {
                        Task {
                            await viewModel.selectRadius(nil)
                            await viewModel.selectType(nil)
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    // MARK: - Screen Content View (Loading / Error / Empty / List)
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.providers.isEmpty {
            // Full Screen Loading State
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                Text("Finding coaches & academies...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if let error = viewModel.errorMessage, viewModel.providers.isEmpty {
            // Error State with Retry
            ContentUnavailableView {
                Label("Unable to Load", systemImage: "wifi.exclamationmark")
            } description: {
                Text(error)
            } actions: {
                Button("Try Again") {
                    Task {
                        await viewModel.loadInitialData()
                    }
                }
                .buttonStyle(.borderedProminent)
            }

        } else if viewModel.isEmpty {
            // Empty State
            ContentUnavailableView {
                Label("No Providers Found", systemImage: "person.slash")
            } description: {
                Text("No coaches or academies match your current filters. Try searching for another city, adjusting your radius, or clearing filters.")
            } actions: {
                if viewModel.selectedActivity != nil || !viewModel.citySearchQuery.isEmpty || viewModel.selectedRadiusKm != nil || viewModel.selectedType != nil {
                    Button("Clear Filters") {
                        viewModel.citySearchQuery = ""
                        viewModel.selectedRadiusKm = nil
                        viewModel.selectedType = nil
                        Task {
                            await viewModel.selectActivity(nil)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }

        } else {
            // Providers List with Infinite Scroll & Pull-to-Refresh
            List {
                ForEach(viewModel.providers) { provider in
                    NavigationLink(value: provider) {
                        ProviderRowView(provider: provider)
                    }
                    .task {
                        await viewModel.loadMoreIfNeeded(currentProvider: provider)
                    }
                }

                // Bottom Pagination Spinner
                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView("Loading more...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}

#Preview {
    ProviderListView()
}
