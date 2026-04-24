import SwiftUI
import SwiftData

enum LeaderboardFilter: String, CaseIterable {
    case all = "All Spots"
    case bookmarked = "Bookmarked"
}

struct LeaderboardView: View {

    @Query private var allSpots: [StudySpot]
    @State private var filter: LeaderboardFilter = .all

    private var rankedSpots: [StudySpot] {
        let pool = filter == .bookmarked
            ? allSpots.filter(\.isBookmarked)
            : allSpots

        return pool
            .filter { !$0.reviews.isEmpty }
            .sorted { $0.averageRating > $1.averageRating }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Filter", selection: $filter) {
                    ForEach(LeaderboardFilter.allCases, id: \.self) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if rankedSpots.isEmpty {
                    ContentUnavailableView(
                        filter == .bookmarked ? "No Bookmarks Yet" : "No Rated Spots",
                        systemImage: filter == .bookmarked ? "bookmark" : "trophy",
                        description: Text(
                            filter == .bookmarked
                                ? "Bookmark spots to track your favorites here."
                                : "Spots with reviews will appear here."
                        )
                    )
                } else {
                    List {
                        ForEach(Array(rankedSpots.enumerated()), id: \.element.id) { index, spot in
                            NavigationLink(value: spot) {
                                LeaderboardRowView(rank: index + 1, spot: spot)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Rankings")
            .navigationDestination(for: StudySpot.self) { spot in
                SpotDetailView(spot: spot)
            }
        }
    }
}

struct LeaderboardRowView: View {

    let rank: Int
    let spot: StudySpot

    var body: some View {
        HStack(spacing: 14) {
            // Rank medal / number
            ZStack {
                Circle()
                    .fill(medalColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                if rank <= 3 {
                    Image(systemName: "medal.fill")
                        .foregroundStyle(medalColor)
                } else {
                    Text("\(rank)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(medalColor)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(spot.name)
                    .font(.headline)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text("\(spot.reviews.count) review\(spot.reviews.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let noise = spot.dominantNoiseLevel {
                        Text("·")
                            .foregroundStyle(.secondary)
                        Label(noise.rawValue, systemImage: noise.icon)
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", spot.averageRating))
                        .font(.headline.weight(.bold))
                }
                if spot.isBookmarked {
                    Image(systemName: "bookmark.fill")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var medalColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(white: 0.6)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .secondary
        }
    }
}

#Preview {
    LeaderboardView()
        .modelContainer(for: [StudySpot.self, Review.self], inMemory: true)
}
