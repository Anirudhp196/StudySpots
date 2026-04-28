// Handles text search, noise and crowd filtering, and keeps a list of recently viewed spots.
import Observation
import Foundation

@Observable
final class SearchViewModel {

    var searchText = ""
    var selectedNoiseLevel: NoiseLevel?
    var selectedCrowdDensity: CrowdDensity?

    private(set) var recentSpotIDs: [UUID] = []

    private let recentsKey = "recentSpotIDs"
    private let maxRecents = 5

    init() {
        loadRecents()
    }

    var hasActiveFilters: Bool {
        selectedNoiseLevel != nil || selectedCrowdDensity != nil
    }

    func filtered(_ spots: [StudySpot]) -> [StudySpot] {
        spots.filter { spot in
            let matchesText = searchText.isEmpty ||
                spot.name.localizedCaseInsensitiveContains(searchText) ||
                spot.address.localizedCaseInsensitiveContains(searchText)
            let matchesNoise = selectedNoiseLevel == nil ||
                spot.dominantNoiseLevel == selectedNoiseLevel
            let matchesCrowd = selectedCrowdDensity == nil ||
                spot.dominantCrowdDensity == selectedCrowdDensity
            return matchesText && matchesNoise && matchesCrowd
        }
    }

    func clearFilters() {
        selectedNoiseLevel = nil
        selectedCrowdDensity = nil
    }

    func recordRecentSpot(_ id: UUID) {
        var ids = recentSpotIDs.filter { $0 != id }
        ids.insert(id, at: 0)
        recentSpotIDs = Array(ids.prefix(maxRecents))
        saveRecents()
    }

    func clearRecents() {
        recentSpotIDs = []
        saveRecents()
    }

    func recentSpots(from all: [StudySpot]) -> [StudySpot] {
        recentSpotIDs.compactMap { id in all.first { $0.id == id } }
    }

    private func loadRecents() {
        guard let data = UserDefaults.standard.data(forKey: recentsKey),
              let ids = try? JSONDecoder().decode([UUID].self, from: data)
        else { return }
        recentSpotIDs = ids
    }

    private func saveRecents() {
        guard let data = try? JSONEncoder().encode(recentSpotIDs) else { return }
        UserDefaults.standard.set(data, forKey: recentsKey)
    }
}
