// Main feed showing spots sorted by distance, with swipeable cards and noise/crowd filters.
import SwiftUI
import SwiftData
internal import CoreLocation

struct FeedView: View {

    @Query private var allSpots: [StudySpot]
    @Environment(LocationViewModel.self) private var locationVM
    @State private var showAddSpot = false
    @State private var noiseFilter: NoiseLevel? = nil
    @State private var crowdFilter: CrowdDensity? = nil
    @AppStorage("swipeHintDismissed") private var swipeHintDismissed = false

    private var hasActiveFilters: Bool {
        noiseFilter != nil || crowdFilter != nil
    }

    private var spots: [StudySpot] {
        var filtered = allSpots
        if let n = noiseFilter { filtered = filtered.filter { $0.dominantNoiseLevel == n } }
        if let c = crowdFilter { filtered = filtered.filter { $0.dominantCrowdDensity == c } }
        return locationVM.sorted(filtered)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterChips
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                if !swipeHintDismissed && !spots.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.draw.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                        Text("Swipe right on a card to bookmark it")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            withAnimation { swipeHintDismissed = true }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.blue.opacity(0.06))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                Divider()

                Group {
                    if spots.isEmpty {
                        ContentUnavailableView(
                            hasActiveFilters ? "No Matching Spots" : "No Study Spots",
                            systemImage: hasActiveFilters ? "line.3.horizontal.decrease.circle" : "building.columns",
                            description: Text(hasActiveFilters
                                ? "Try clearing your filters."
                                : "Study spots will appear here once they're loaded.")
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(spots) { spot in
                                    NavigationLink(value: spot) {
                                        SwipeableSpotCard(
                                            spot: spot,
                                            distanceLabel: locationVM.formattedDistance(to: spot)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Nearby Spots")
            .navigationDestination(for: StudySpot.self) { spot in
                SpotDetailView(spot: spot)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        locationStatusButton
                        Button {
                            showAddSpot = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddSpot) {
                AddSpotView()
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if hasActiveFilters {
                    Button {
                        noiseFilter = nil
                        crowdFilter = nil
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
                        isSelected: noiseFilter == level, color: .blue
                    ) {
                        noiseFilter = noiseFilter == level ? nil : level
                    }
                }

                ForEach(CrowdDensity.allCases, id: \.self) { density in
                    FilterChip(
                        label: density.rawValue, icon: density.icon,
                        isSelected: crowdFilter == density, color: .purple
                    ) {
                        crowdFilter = crowdFilter == density ? nil : density
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var locationStatusButton: some View {
        switch locationVM.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            Image(systemName: "location.fill")
                .foregroundStyle(.green)
        case .denied, .restricted:
            Image(systemName: "location.slash.fill")
                .foregroundStyle(.red)
        default:
            Image(systemName: "location")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    FeedView()
        .environment(LocationViewModel())
        .modelContainer(for: [StudySpot.self, Review.self], inMemory: true)
}
