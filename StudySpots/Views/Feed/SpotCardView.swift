// Card showing a spot's name, address, rating, noise level, and crowd density.
import SwiftUI

struct SpotCardView: View {

    let spot: StudySpot
    let distanceLabel: String?

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(ratingColor)
                .frame(width: 4)
                .padding(.vertical, 12)
                .padding(.leading, 12)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(spot.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(spot.address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        if spot.isBookmarked {
                            Image(systemName: "bookmark.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                        if let distanceLabel {
                            Text(distanceLabel)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Divider()

                HStack(spacing: 10) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(spot.averageRating > 0
                             ? String(format: "%.1f", spot.averageRating)
                             : "No ratings")
                            .foregroundStyle(spot.averageRating > 0 ? .primary : .secondary)
                    }
                    .font(.subheadline.weight(.medium))

                    Spacer()

                    if let noise = spot.dominantNoiseLevel {
                        Label(noise.rawValue, systemImage: noise.icon)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.12))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }

                    if let crowd = spot.dominantCrowdDensity {
                        Label(crowd.rawValue, systemImage: crowd.icon)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.purple.opacity(0.12))
                            .foregroundStyle(.purple)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
        }
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
    }

    private var ratingColor: Color {
        let r = spot.averageRating
        if r == 0 { return .secondary.opacity(0.3) }
        if r >= 4.0 { return .green }
        if r >= 3.0 { return .yellow }
        return .red
    }
}
