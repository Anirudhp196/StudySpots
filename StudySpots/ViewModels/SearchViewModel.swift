import Observation

@Observable
final class SearchViewModel {

    var searchText = ""
    var selectedNoiseLevel: NoiseLevel?
    var selectedCrowdDensity: CrowdDensity?

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
}
