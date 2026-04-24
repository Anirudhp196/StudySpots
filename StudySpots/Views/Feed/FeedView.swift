import SwiftUI
import SwiftData

struct FeedView: View {

    @Query private var allSpots: [StudySpot]
    @Environment(LocationViewModel.self) private var locationVM

    private var spots: [StudySpot] {
        locationVM.sorted(allSpots)
    }

    var body: some View {
        NavigationStack {
            Group {
                if spots.isEmpty {
                    ContentUnavailableView(
                        "No Study Spots",
                        systemImage: "building.columns",
                        description: Text("Study spots will appear here once they're loaded.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(spots) { spot in
                                NavigationLink(value: spot) {
                                    SpotCardView(
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
            .navigationTitle("Nearby Spots")
            .navigationDestination(for: StudySpot.self) { spot in
                SpotDetailView(spot: spot)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    locationStatusButton
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
