// Data model for a single review, storing rating, noise level, crowd density, and optional notes.
import SwiftData
import Foundation

@Model
final class Review {
    var id: UUID
    var authorName: String
    var rating: Double
    var noiseLevel: NoiseLevel
    var crowdDensity: CrowdDensity
    var notes: String
    var timestamp: Date
    var isOwnReview: Bool
    var spot: StudySpot?

    init(
        id: UUID = UUID(),
        authorName: String,
        rating: Double,
        noiseLevel: NoiseLevel,
        crowdDensity: CrowdDensity,
        notes: String,
        timestamp: Date = .now,
        isOwnReview: Bool = false
    ) {
        self.id = id
        self.authorName = authorName
        self.rating = rating
        self.noiseLevel = noiseLevel
        self.crowdDensity = crowdDensity
        self.notes = notes
        self.timestamp = timestamp
        self.isOwnReview = isOwnReview
    }
}
