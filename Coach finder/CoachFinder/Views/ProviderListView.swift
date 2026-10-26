import SwiftUI

/// Main Provider List screen with city search, activity filter pills, pagination, and pull-to-refresh.
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
                prompt: "Search by city (e.g. London, Delhi)"
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
                Text("No coaches or academies match your current filters. Try searching for another city or selecting a different activity.")
            } actions: {
                if viewModel.selectedActivity != nil || !viewModel.citySearchQuery.isEmpty {
                    Button("Clear Filters") {
                        viewModel.citySearchQuery = ""
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
