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

    static func seedCafes(into context: ModelContext) {
        let cafes: [(name: String, address: String, lat: Double, lon: Double)] = [
            (
                name: "Green Line Café",
                address: "4239 Baltimore Ave, Philadelphia, PA",
                lat: 39.9479,
                lon: -75.2007
            ),
            (
                name: "La Colombe Coffee",
                address: "130 S 19th St, Philadelphia, PA",
                lat: 39.9494,
                lon: -75.1731
            ),
            (
                name: "Elixr Coffee Roasters",
                address: "207 S Broad St, Philadelphia, PA",
                lat: 39.9463,
                lon: -75.1633
            ),
            (
                name: "Menagerie Coffee",
                address: "18 S 3rd St, Philadelphia, PA",
                lat: 39.9495,
                lon: -75.1444
            ),
            (
                name: "Good Karma Café",
                address: "4009 Walnut St, Philadelphia, PA",
                lat: 39.9520,
                lon: -75.2001
            ),
            (
                name: "Haraz Coffee House",
                address: "4517 Baltimore Ave, Philadelphia, PA",
                lat: 39.9461,
                lon: -75.2088
            )
        ]

        for cafeData in cafes {
            let spot = StudySpot(
                name: cafeData.name,
                address: cafeData.address,
                latitude: cafeData.lat,
                longitude: cafeData.lon
            )
            context.insert(spot)

            let reviews = sampleReviews(for: cafeData.name)
            for review in reviews {
                review.spot = spot
                context.insert(review)
            }
        }
    }

    private static func sampleReviews(for spotName: String) -> [Review] {
        switch spotName {
        case "Green Line Café":
            return [
                Review(authorName: "Maya T.", rating: 4.5, noiseLevel: .moderate, crowdDensity: .moderate, notes: "West Philly staple. Great for a few hours of focused work, especially on weekday mornings."),
                Review(authorName: "Jordan K.", rating: 4.0, noiseLevel: .moderate, crowdDensity: .busy, notes: "Gets packed on weekends but the vibe is warm and welcoming. Strong coffee."),
                Review(authorName: "Priya S.", rating: 5.0, noiseLevel: .quiet, crowdDensity: .moderate, notes: "My go-to off-campus café. Outlets at most tables and the staff never rush you.")
            ]
        case "La Colombe Coffee":
            return [
                Review(authorName: "Chris W.", rating: 4.5, noiseLevel: .moderate, crowdDensity: .busy, notes: "Iconic Philly café. Beautiful space in Rittenhouse, perfect for working a few hours between classes."),
                Review(authorName: "Nia B.", rating: 4.0, noiseLevel: .loud, crowdDensity: .busy, notes: "Can get loud but the draft latte makes it worth it. Grab a corner seat early."),
                Review(authorName: "Sam P.", rating: 5.0, noiseLevel: .moderate, crowdDensity: .moderate, notes: "Best coffee in Philly hands down. Midweek afternoons are quiet enough to get real work done.")
            ]
        case "Elixr Coffee Roasters":
            return [
                Review(authorName: "Dev A.", rating: 5.0, noiseLevel: .quiet, crowdDensity: .empty, notes: "Seriously underrated study spot. High ceilings, soft music, and the best pour-over in the city."),
                Review(authorName: "Leila N.", rating: 4.5, noiseLevel: .quiet, crowdDensity: .moderate, notes: "Calm, professional atmosphere. Great for deep focus sessions — people here are mostly working."),
                Review(authorName: "Marcus F.", rating: 4.0, noiseLevel: .moderate, crowdDensity: .moderate, notes: "Love the industrial aesthetic. Plenty of seating and not too crowded on weekday mornings.")
            ]
        case "Menagerie Coffee":
            return [
                Review(authorName: "Sophie L.", rating: 4.5, noiseLevel: .quiet, crowdDensity: .empty, notes: "Hidden gem in Old City. Almost never crowded and the space is really cozy."),
                Review(authorName: "Eli R.", rating: 4.0, noiseLevel: .quiet, crowdDensity: .empty, notes: "Perfect if you want to escape campus. Small but charming, great for reading or writing."),
                Review(authorName: "Aisha G.", rating: 4.5, noiseLevel: .moderate, crowdDensity: .moderate, notes: "Friendly staff and good Wi-Fi. A bit of a trek from Penn but totally worth it for a change of scenery.")
            ]
        case "Good Karma Café":
            return [
                Review(authorName: "Ravi M.", rating: 4.0, noiseLevel: .moderate, crowdDensity: .moderate, notes: "Chill West Philly spot right near campus. Great for casual studying over a long breakfast."),
                Review(authorName: "Tess H.", rating: 4.5, noiseLevel: .quiet, crowdDensity: .empty, notes: "Underrated and just a few blocks from Penn. Mornings here are peaceful and the food is great too."),
                Review(authorName: "Kwame O.", rating: 3.5, noiseLevel: .moderate, crowdDensity: .busy, notes: "Popular with locals on weekends. Better for lighter work but the coffee is solid.")
            ]
        case "Haraz Coffee House":
            return [
                Review(authorName: "Layla A.", rating: 5.0, noiseLevel: .quiet, crowdDensity: .empty, notes: "Absolutely love this place. Yemeni coffee is incredible and the atmosphere is warm and focused."),
                Review(authorName: "Omar S.", rating: 5.0, noiseLevel: .quiet, crowdDensity: .moderate, notes: "One of the best cafés in Philly. Community-rooted, great Wi-Fi, and the staff make you feel at home."),
                Review(authorName: "Zara K.", rating: 4.5, noiseLevel: .moderate, crowdDensity: .moderate, notes: "A gem on Baltimore Ave. Spacious enough to spread out and the qishr spiced coffee is a must-try.")
            ]
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
