import SwiftUI

/// A clean card-style row displaying provider details (name, type badge, city, distance).
struct ProviderRowView: View {
    let provider: Provider

    private var isCoach: Bool {
        provider.type.uppercased() == "COACH" || provider.type.uppercased() == "INDIVIDUAL"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(provider.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Spacer()

                // Badge for COACH/INDIVIDUAL or ACADEMY
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

            // Location and Distance
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(provider.city)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let distance = provider.formattedDistance {
                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                        Text(distance)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.blue)
                } else if let lat = provider.lat, let lng = provider.lng {
                    Text(String(format: "(%.2f, %.2f)", lat, lng))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
