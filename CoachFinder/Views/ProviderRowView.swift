import SwiftUI

/// A clean card-style row displaying provider details (name, type badge, city).
struct ProviderRowView: View {
    let provider: Provider

    private var isCoach: Bool {
        provider.type.uppercased() == "COACH"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(provider.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Spacer()

                // Badge for COACH or ACADEMY
                Text(provider.type.uppercased())
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isCoach ? Color.blue.opacity(0.15) : Color.orange.opacity(0.15))
                    )
                    .foregroundStyle(isCoach ? Color.blue : Color.orange)
            }

            // Location with pin icon
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(provider.city)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let lat = provider.lat, let lng = provider.lng {
                    Text(String(format: "(%.2f, %.2f)", lat, lng))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
