import SwiftUI
import SwiftData

private enum LeaderboardScope: String, CaseIterable {
    case all = "All Spots"
    case saved = "Saved"
}

struct LeaderboardView: View {

    @Query private var allSpots: [StudySpot]

    @State private var scope: LeaderboardScope = .all
    @State private var showFilters = false
    @State private var minReviews: Int = 1
    @State private var minScore: Double = 0.0

    private var rankedSpots: [StudySpot] {
        let pool = scope == .saved ? allSpots.filter(\.isBookmarked) : allSpots
        return pool
            .filter { $0.reviews.count >= minReviews }
            .filter { $0.averageRating >= minScore }
            .sorted { $0.averageRating > $1.averageRating }
    }

    private var hasActiveFilters: Bool {
        minReviews > 1 || minScore > 0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Scope", selection: $scope) {
                    ForEach(LeaderboardScope.allCases, id: \.self) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 10)

                if showFilters {
                    filterPanel
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Divider()

                if rankedSpots.isEmpty {
                    ContentUnavailableView(
                        scope == .saved ? "No Saved Spots" : "No Rated Spots",
                        systemImage: scope == .saved ? "bookmark" : "trophy",
                        description: Text(
                            hasActiveFilters
                                ? "Try relaxing your filters."
                                : scope == .saved
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
            .animation(.easeInOut(duration: 0.2), value: showFilters)
            .navigationTitle("Rankings")
            .navigationDestination(for: StudySpot.self) { spot in
                SpotDetailView(spot: spot)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation { showFilters.toggle() }
                    } label: {
                        Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundStyle(hasActiveFilters ? .blue : .primary)
                    }
                }
            }
        }
    }

    private var filterPanel: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Filters")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if hasActiveFilters {
                    Button("Reset") {
                        minReviews = 1
                        minScore = 0
                    }
                    .font(.caption)
                    .foregroundStyle(.red)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Min reviews")
                        .font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text("\(minReviews)+")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 32, alignment: .trailing)
                }
                Slider(value: Binding(
                    get: { Double(minReviews) },
                    set: { minReviews = Int($0) }
                ), in: 1...10, step: 1)
                .tint(.blue)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Min score")
                        .font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text(minScore > 0 ? String(format: "%.1f+", minScore) : "Any")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.yellow)
                        .frame(width: 36, alignment: .trailing)
                }
                Slider(value: $minScore, in: 0...5, step: 0.5)
                    .tint(.yellow)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct LeaderboardRowView: View {

    let rank: Int
    let spot: StudySpot

    var body: some View {
        HStack(spacing: 14) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(medalColor.opacity(rank <= 3 ? 0.2 : 0.1))
                    .frame(width: 42, height: 42)
                if rank <= 3 {
                    Image(systemName: "medal.fill")
                        .font(.body)
                        .foregroundStyle(medalColor)
                } else {
                    Text("\(rank)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(medalColor)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(spot.name)
                    .font(.headline).lineLimit(1)
                HStack(spacing: 4) {
                    Text("\(spot.reviews.count) review\(spot.reviews.count == 1 ? "" : "s")")
                        .font(.caption).foregroundStyle(.secondary)
                    if let noise = spot.dominantNoiseLevel {
                        Text("·").foregroundStyle(.secondary)
                        Label(noise.rawValue, systemImage: noise.icon)
                            .font(.caption).foregroundStyle(.blue)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow).font(.caption)
                    Text(String(format: "%.1f", spot.averageRating))
                        .font(.headline.weight(.bold))
                }
                if spot.isBookmarked {
                    Image(systemName: "bookmark.fill")
                        .font(.caption2).foregroundStyle(.blue)
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(rank <= 3 ? medalColor.opacity(0.06) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .listRowBackground(Color.clear)
    }

    private var medalColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(white: 0.55)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .secondary
        }
    }
}

#Preview {
    LeaderboardView()
        .modelContainer(for: [StudySpot.self, Review.self], inMemory: true)
}
