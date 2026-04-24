import SwiftUI
import SwiftData

struct ProfileView: View {

    @Query private var allSpots: [StudySpot]
    @Query private var allReviews: [Review]

    private var bookmarkedSpots: [StudySpot] {
        allSpots.filter(\.isBookmarked)
    }

    var body: some View {
        NavigationStack {
            List {
                // Stats section
                Section {
                    statsGrid
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                // Bookmarks section
                Section {
                    if bookmarkedSpots.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "bookmark.slash")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                                Text("No bookmarked spots yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Tap the bookmark icon on any spot to save it.")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical)
                            Spacer()
                        }
                    } else {
                        ForEach(bookmarkedSpots) { spot in
                            NavigationLink(value: spot) {
                                BookmarkedSpotRow(spot: spot)
                            }
                        }
                    }
                } header: {
                    Label("Saved Spots", systemImage: "bookmark.fill")
                }
            }
            .navigationTitle("Profile")
            .navigationDestination(for: StudySpot.self) { spot in
                SpotDetailView(spot: spot)
            }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatTileView(value: "\(allSpots.count)", label: "Total Spots", icon: "building.columns.fill", color: .blue)
            StatTileView(value: "\(bookmarkedSpots.count)", label: "Saved", icon: "bookmark.fill", color: .purple)
            StatTileView(value: "\(allReviews.count)", label: "Reviews", icon: "star.fill", color: .yellow)
        }
        .padding()
    }
}

struct StatTileView: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct BookmarkedSpotRow: View {
    let spot: StudySpot

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background(.blue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(spot.name)
                    .font(.headline)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption2)
                    Text(spot.averageRating > 0
                         ? String(format: "%.1f", spot.averageRating)
                         : "No ratings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text("\(spot.reviews.count) reviews")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [StudySpot.self, Review.self], inMemory: true)
}
