//
//  ActivityFeedView.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

public struct ActivityFeedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SDActivity.timestamp, order: .reverse) private var activities: [SDActivity]
    @State private var refreshId = UUID()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if activities.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 36))
                                .foregroundColor(.secondary)
                            Text("No recent activity.")
                                .font(.headline)
                            Text("When you or friends add expenses or settle up, activity will appear here.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .padding(.horizontal, 16)
                        .elevatedCard()
                    } else {
                        ForEach(activities) { act in
                            HStack(spacing: 12) {
                                Image(systemName: act.type.systemImage)
                                    .font(.system(size: 18))
                                    .foregroundColor(act.type.color)
                                    .frame(width: 40, height: 40)
                                    .background(act.type.color.opacity(0.12))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(act.message)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)

                                    Text(act.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                            .elevatedCard(cornerRadius: 12, padding: 12)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .id(refreshId)
            .refreshable {
                HapticManager.impact(.light)
                refreshId = UUID()
                await CloudSyncEngine.shared.syncAll(modelContext: modelContext)
            }
            .background(Color.surfaceSecondary.ignoresSafeArea())
            .navigationTitle("Activity Feed")
            .onReceive(NotificationCenter.default.publisher(for: .appDataDidChange)) { _ in
                refreshId = UUID()
            }
        }
    }
}
