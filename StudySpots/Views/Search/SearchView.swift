import SwiftUI
import SwiftData

struct SearchView: View {

    @Query private var allSpots: [StudySpot]
    @Environment(LocationViewModel.self) private var locationVM
    @State private var searchVM = SearchViewModel()
    @State private var selectedSpot: StudySpot?

    private var isSearching: Bool {
        !searchVM.searchText.isEmpty || searchVM.hasActiveFilters
    }

    private var searchResults: [StudySpot] {
        locationVM.sorted(searchVM.filtered(allSpots))
    }

    private var nearbySpots: [StudySpot] {
        Array(locationVM.sorted(allSpots).prefix(5))
    }

    private var recentSpots: [StudySpot] {
        searchVM.recentSpots(from: allSpots)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterChips
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                Divider()

                if isSearching {
                    searchResultsList
                } else {
                    browseView
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchVM.searchText, prompt: "Search study spots…")
            .navigationDestination(for: StudySpot.self) { spot in
                SpotDetailView(spot: spot)
                    .onAppear { searchVM.recordRecentSpot(spot.id) }
            }
        }
    }

    // MARK: - Browse (empty search)

    private var browseView: some View {
        List {
            if !recentSpots.isEmpty {
                Section {
                    ForEach(recentSpots) { spot in
                        NavigationLink(value: spot) {
                            RecentSpotRow(spot: spot)
                        }
                    }
                } header: {
                    HStack {
                        Label("Recents", systemImage: "clock")
                        Spacer()
                        Button("Clear") { searchVM.clearRecents() }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                if nearbySpots.isEmpty {
                    Text("Enable location to see nearby spots.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(nearbySpots) { spot in
                        NavigationLink(value: spot) {
                            SpotCardView(
                                spot: spot,
                                distanceLabel: locationVM.formattedDistance(to: spot)
                            )
                            .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        }
                        .listRowSeparator(.hidden)
                    }
                }
            } header: {
                Label("Spots in Your Area", systemImage: "location.fill")
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Search results

    private var searchResultsList: some View {
        Group {
            if searchResults.isEmpty {
                ContentUnavailableView.search(text: searchVM.searchText)
            } else {
                List(searchResults) { spot in
                    NavigationLink(value: spot) {
                        SpotCardView(
                            spot: spot,
                            distanceLabel: locationVM.formattedDistance(to: spot)
                        )
                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
    }

    // MARK: - Filter chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if searchVM.hasActiveFilters {
                    Button {
                        searchVM.clearFilters()
                    } label: {
                        Label("Clear", systemImage: "xmark.circle.fill")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(.red.opacity(0.12))
                            .foregroundStyle(.red)
                            .clipShape(Capsule())
                    }
                }

                ForEach(NoiseLevel.allCases, id: \.self) { level in
                    FilterChip(
                        label: level.rawValue, icon: level.icon,
                        isSelected: searchVM.selectedNoiseLevel == level, color: .blue
                    ) {
                        searchVM.selectedNoiseLevel =
                            searchVM.selectedNoiseLevel == level ? nil : level
                    }
                }

                ForEach(CrowdDensity.allCases, id: \.self) { density in
                    FilterChip(
                        label: density.rawValue, icon: density.icon,
                        isSelected: searchVM.selectedCrowdDensity == density, color: .purple
                    ) {
                        searchVM.selectedCrowdDensity =
                            searchVM.selectedCrowdDensity == density ? nil : density
                    }
                }
            }
        }
    }
}

struct RecentSpotRow: View {
    let spot: StudySpot

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock")
                .foregroundStyle(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(spot.name)
                    .font(.subheadline)
                if spot.averageRating > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2).foregroundStyle(.yellow)
                        Text(String(format: "%.1f", spot.averageRating))
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image(systemName: "arrow.up.left")
                .font(.caption2).foregroundStyle(.tertiary)
        }
    }
}

struct FilterChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.1))
                .foregroundStyle(isSelected ? .white : color)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    SearchView()
        .environment(LocationViewModel())
        .modelContainer(for: [StudySpot.self, Review.self], inMemory: true)
}
