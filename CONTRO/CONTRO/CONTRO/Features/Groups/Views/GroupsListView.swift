//
//  GroupsListView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct GroupsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SDGroup.updatedAt, order: .reverse) private var allGroups: [SDGroup]

    @State private var selectedCategory: GroupCategory? = nil
    @State private var refreshId = UUID()
    @State private var showingCreateGroup: Bool = false
    @State private var searchText: String = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Category Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            filterPill(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }

                            ForEach(GroupCategory.allCases) { cat in
                                filterPill(title: "\(cat.defaultEmoji) \(cat.displayName)", isSelected: selectedCategory == cat) {
                                    selectedCategory = cat
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Groups List
                    if filteredGroups.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "folder.badge.questionmark")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("No groups found.")
                                .font(.headline)
                            Text("Create a group for your next trip, apartment, or outing!")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            PrimaryButton("Create New Group", icon: "plus") {
                                showingCreateGroup = true
                            }
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .padding(.horizontal, 16)
                        .elevatedCard()
                        .padding(.horizontal, 16)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredGroups) { group in
                                NavigationLink(destination: GroupDetailView(group: group)) {
                                    groupCard(group: group)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 12)
            }
            .id(refreshId)
            .refreshable {
                HapticManager.impact(.light)
                refreshId = UUID()
                await CloudSyncEngine.shared.syncAll(modelContext: modelContext)
            }
            .background(Color.surfaceSecondary.ignoresSafeArea())
            .navigationTitle("Groups")
            .searchable(text: $searchText, prompt: "Search groups")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        HapticManager.impact(.medium)
                        showingCreateGroup = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
            }
            .sheet(isPresented: $showingCreateGroup) {
                CreateGroupView()
            }
            .onChange(of: showingCreateGroup) { _, isShowing in
                if !isShowing { refreshId = UUID() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .appDataDidChange)) { _ in
                refreshId = UUID()
            }
        }
    }

    private var filteredGroups: [SDGroup] {
        allGroups.filter { g in
            let matchesCategory = selectedCategory == nil || g.category == selectedCategory
            let matchesSearch = searchText.isEmpty || g.name.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch && !g.isArchived
        }
    }

    private func filterPill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.appPrimary : Color.surfaceCard)
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.cardBorder, lineWidth: 1)
                )
        }
    }

    private func groupCard(group: SDGroup) -> some View {
        HStack(spacing: 16) {
            Text(group.emoji)
                .font(.system(size: 38))
                .frame(width: 56, height: 56)
                .background(Color.surfaceSecondary)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                HStack(spacing: 6) {
                    Text("\(group.members.count) members")
                    Text("•")
                    Text("\(group.activeExpenses.count) expenses")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .elevatedCard()
    }
}
