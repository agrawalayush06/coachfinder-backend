import SwiftUI

/// Horizontal scrolling row of activity filter pills ("All", "Cricket", "Badminton", etc.)
struct ActivityFilterPillsView: View {
    let activities: [Activity]
    let selectedActivity: Activity?
    let onSelect: (Activity?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" Pill
                FilterPillButton(
                    title: "All",
                    isSelected: selectedActivity == nil
                ) {
                    onSelect(nil)
                }

                // Individual Activity Pills
                ForEach(activities) { activity in
                    FilterPillButton(
                        title: activity.name,
                        isSelected: selectedActivity == activity
                    ) {
                        onSelect(activity)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

private struct FilterPillButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
                )
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
