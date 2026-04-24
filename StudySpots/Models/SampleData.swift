import SwiftData
import Foundation

enum SampleData {

    /// Inserts UPenn study spots with sample reviews into the model context.
    /// Should only be called once — guard with UserDefaults to avoid duplication.
    static func seed(into context: ModelContext) {
        let spots: [(name: String, address: String, lat: Double, lon: Double)] = [
            (
                name: "Van Pelt Library",
                address: "3420 Walnut St, Philadelphia, PA",
                lat: 39.9525,
                lon: -75.1931
            ),
            (
                name: "Weigle Information Commons",
                address: "3420 Walnut St (Lower Level), Philadelphia, PA",
                lat: 39.9524,
                lon: -75.1930
            ),
            (
                name: "Huntsman Hall",
                address: "3730 Walnut St, Philadelphia, PA",
                lat: 39.9527,
                lon: -75.1975
            ),
            (
                name: "Houston Hall",
                address: "3417 Spruce St, Philadelphia, PA",
                lat: 39.9509,
                lon: -75.1932
            ),
            (
                name: "Fisher Fine Arts Library",
                address: "220 S 34th St, Philadelphia, PA",
                lat: 39.9502,
                lon: -75.1918
            ),
            (
                name: "Levine Hall",
                address: "3330 Walnut St, Philadelphia, PA",
                lat: 39.9539,
                lon: -75.1904
            ),
            (
                name: "Class of 1920 Commons",
                address: "3417 Walnut St, Philadelphia, PA",
                lat: 39.9522,
                lon: -75.1919
            ),
            (
                name: "Hill College House Dining",
                address: "3333 Walnut St, Philadelphia, PA",
                lat: 39.9518,
                lon: -75.1906
            ),
            (
                name: "Perelman Quad",
                address: "36th & Spruce St, Philadelphia, PA",
                lat: 39.9511,
                lon: -75.1930
            ),
            (
                name: "Singh Center for Nanotechnology",
                address: "3205 Walnut St, Philadelphia, PA",
                lat: 39.9536,
                lon: -75.1927
            )
        ]

        for spotData in spots {
            let spot = StudySpot(
                name: spotData.name,
                address: spotData.address,
                latitude: spotData.lat,
                longitude: spotData.lon
            )
            context.insert(spot)

            let reviews = sampleReviews(for: spotData.name)
            for review in reviews {
                review.spot = spot
                context.insert(review)
            }
        }
    }

    private static func sampleReviews(for spotName: String) -> [Review] {
        switch spotName {
        case "Van Pelt Library":
            return [
                Review(authorName: "Alex R.", rating: 4.5, noiseLevel: .quiet, crowdDensity: .moderate, notes: "Great quiet floors on 3 and 4. Gets busy during finals but still manageable."),
                Review(authorName: "Jamie L.", rating: 5.0, noiseLevel: .quiet, crowdDensity: .moderate, notes: "My go-to. Plenty of outlets and the natural light is amazing."),
                Review(authorName: "Sam K.", rating: 4.0, noiseLevel: .quiet, crowdDensity: .busy, notes: "Can get crowded but always find a spot if you come early.")
            ]
        case "Weigle Information Commons":
            return [
                Review(authorName: "Taylor M.", rating: 4.0, noiseLevel: .moderate, crowdDensity: .moderate, notes: "Collaborative space on the lower level of Van Pelt. Good for group work."),
                Review(authorName: "Jordan P.", rating: 3.5, noiseLevel: .moderate, crowdDensity: .busy, notes: "Can get loud but the tech resources are great.")
            ]
        case "Huntsman Hall":
            return [
                Review(authorName: "Morgan C.", rating: 4.5, noiseLevel: .moderate, crowdDensity: .moderate, notes: "Beautiful building, lots of seating. Great coffee nearby too."),
                Review(authorName: "Casey D.", rating: 4.0, noiseLevel: .moderate, crowdDensity: .busy, notes: "Busy but lots of tables. Good energy for staying productive.")
            ]
        case "Houston Hall":
            return [
                Review(authorName: "Riley B.", rating: 3.5, noiseLevel: .moderate, crowdDensity: .moderate, notes: "Nice historic vibe. Has a fireplace lounge that's cozy in winter."),
                Review(authorName: "Quinn A.", rating: 4.0, noiseLevel: .quiet, crowdDensity: .empty, notes: "Often overlooked but really peaceful in the mornings.")
            ]
        case "Fisher Fine Arts Library":
            return [
                Review(authorName: "Avery S.", rating: 5.0, noiseLevel: .quiet, crowdDensity: .empty, notes: "Hidden gem. Stunning architecture, almost always empty. Best for deep work."),
                Review(authorName: "Drew W.", rating: 4.5, noiseLevel: .quiet, crowdDensity: .empty, notes: "Feels like studying in a cathedral. Absolute focus mode.")
            ]
        case "Levine Hall":
            return [
                Review(authorName: "Blake H.", rating: 4.0, noiseLevel: .moderate, crowdDensity: .moderate, notes: "Great for CS students, near all the labs. Good vibe."),
                Review(authorName: "Parker N.", rating: 3.5, noiseLevel: .loud, crowdDensity: .busy, notes: "Can be chaotic before class but good tables on the upper floors.")
            ]
        case "Class of 1920 Commons":
            return [
                Review(authorName: "Skylar T.", rating: 4.0, noiseLevel: .moderate, crowdDensity: .moderate, notes: "Good food options nearby. Works well for a study lunch break."),
                Review(authorName: "Reese F.", rating: 3.5, noiseLevel: .loud, crowdDensity: .busy, notes: "Lively atmosphere, better for casual work than deep focus.")
            ]
        case "Hill College House Dining":
            return [
                Review(authorName: "Charlie G.", rating: 3.0, noiseLevel: .loud, crowdDensity: .busy, notes: "More of a social space than a study spot, but works in off-peak hours."),
            ]
        case "Perelman Quad":
            return [
                Review(authorName: "Frankie O.", rating: 4.5, noiseLevel: .moderate, crowdDensity: .moderate, notes: "Outdoor seating is amazing in nice weather. Very inspiring setting."),
                Review(authorName: "Indie V.", rating: 4.0, noiseLevel: .quiet, crowdDensity: .empty, notes: "Early mornings here are peaceful and beautiful.")
            ]
        case "Singh Center for Nanotechnology":
            return [
                Review(authorName: "Lane Z.", rating: 4.5, noiseLevel: .quiet, crowdDensity: .empty, notes: "Beautiful modern building. Rooftop area is incredible on a clear day."),
                Review(authorName: "Shea Y.", rating: 4.0, noiseLevel: .quiet, crowdDensity: .empty, notes: "Not many people know about this spot. Super clean and modern.")
            ]
        default:
            return []
        }
    }
}
