//
//  MainTabView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct MainTabView: View {
    @State private var selectedTab: Int = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            HomeDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            GroupsListView()
                .tabItem {
                    Label("Groups", systemImage: "folder.fill")
                }
                .tag(1)

            ActivityFeedView()
                .tabItem {
                    Label("Activity", systemImage: "bell.fill")
                }
                .tag(2)

            InsightsDashboardView()
                .tabItem {
                    Label("Insights", systemImage: "chart.pie.fill")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
        }
        .tint(Color.appPrimary)
    }
}
