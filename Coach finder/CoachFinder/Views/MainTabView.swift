import SwiftUI

/// Root Tab View containing the Coaches List tab and Map tab.
/// Owns a single `ProviderListViewModel` as the single source of truth,
/// ensuring both tabs share the same loaded/filtered data without redundant network requests.
struct MainTabView: View {
    @State private var listViewModel = ProviderListViewModel()
    @State private var selectedTab: Tab = .list

    enum Tab: Hashable {
        case list
        case map
        case profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Coaches List Screen
            ProviderListView(viewModel: listViewModel)
                .tabItem {
                    Label("Coaches", systemImage: "list.bullet")
                }
                .tag(Tab.list)

            // Tab 2: Providers Map Screen (sharing list data)
            ProviderMapView(sharedProviders: listViewModel.providers)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(Tab.map)

            // Tab 3: Profile Screen
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(Tab.profile)
        }
    }
}

#Preview {
    MainTabView()
}
