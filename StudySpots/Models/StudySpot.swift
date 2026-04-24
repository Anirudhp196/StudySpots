import SwiftData
import CoreLocation

enum NoiseLevel: String, Codable, CaseIterable {
    case quiet = "Quiet"
    case moderate = "Moderate"
    case loud = "Loud"

    var icon: String {
        switch self {
        case .quiet: return "speaker.slash.fill"
        case .moderate: return "speaker.wave.1.fill"
        case .loud: return "speaker.wave.3.fill"
        }
    }
}

enum CrowdDensity: String, Codable, CaseIterable {
    case empty = "Empty"
    case moderate = "Moderate"
    case busy = "Busy"

    var icon: String {
        switch self {
        case .empty: return "person.fill"
        case .moderate: return "person.2.fill"
        case .busy: return "person.3.fill"
        }
    }
}

@Model
final class StudySpot {
    var id: UUID
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var isBookmarked: Bool
    var visitCount: Int

    @Relationship(deleteRule: .cascade, inverse: \Review.spot)
    var reviews: [Review] = []

    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.isBookmarked = false
        self.visitCount = 0
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        return reviews.map(\.rating).reduce(0, +) / Double(reviews.count)
    }

    var dominantNoiseLevel: NoiseLevel? {
        guard !reviews.isEmpty else { return nil }
        return NoiseLevel.allCases.max { a, b in
            reviews.filter { $0.noiseLevel == a }.count <
            reviews.filter { $0.noiseLevel == b }.count
        }
    }

    var dominantCrowdDensity: CrowdDensity? {
        guard !reviews.isEmpty else { return nil }
        return CrowdDensity.allCases.max { a, b in
            reviews.filter { $0.crowdDensity == a }.count <
            reviews.filter { $0.crowdDensity == b }.count
        }
    }

    func distance(from location: CLLocation) -> CLLocationDistance {
        let spotLocation = CLLocation(latitude: latitude, longitude: longitude)
        return location.distance(from: spotLocation)
    }
}
