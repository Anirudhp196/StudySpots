import SwiftUI
import SwiftData

struct SearchView: View {

    @Query private var allSpots: [StudySpot]
    @Environment(LocationViewModel.self) private var locationVM
    @State private var searchVM = SearchViewModel()

    private var results: [StudySpot] {
        locationVM.sorted(searchVM.filtered(allSpots))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterChips
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                Divider()

                Group {
                    if results.isEmpty {
                        ContentUnavailableView.search(text: searchVM.searchText)
                    } else {
                        List(results) { spot in
                            NavigationLink(value: spot) {
                                SpotCardView(
                                    spot: spot,
                                    distanceLabel: locationVM.formattedDistance(to: spot)
                                )
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            }
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchVM.searchText, prompt: "Search study spots…")
            .navigationDestination(for: StudySpot.self) { spot in
                SpotDetailView(spot: spot)
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Clear all
                if searchVM.hasActiveFilters {
                    Button {
                        searchVM.clearFilters()
                    } label: {
                        Label("Clear", systemImage: "xmark.circle.fill")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.red.opacity(0.12))
                            .foregroundStyle(.red)
                            .clipShape(Capsule())
                    }
                }

                // Noise filters
                ForEach(NoiseLevel.allCases, id: \.self) { level in
                    FilterChip(
                        label: level.rawValue,
                        icon: level.icon,
                        isSelected: searchVM.selectedNoiseLevel == level,
                        color: .blue
                    ) {
                        searchVM.selectedNoiseLevel =
                            searchVM.selectedNoiseLevel == level ? nil : level
                    }
                }

                // Crowd filters
                ForEach(CrowdDensity.allCases, id: \.self) { density in
                    FilterChip(
                        label: density.rawValue,
                        icon: density.icon,
                        isSelected: searchVM.selectedCrowdDensity == density,
                        color: .purple
                    ) {
                        searchVM.selectedCrowdDensity =
                            searchVM.selectedCrowdDensity == density ? nil : density
                    }
                }
            }
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
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
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
