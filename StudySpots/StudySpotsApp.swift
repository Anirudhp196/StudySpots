import SwiftUI
import SwiftData

@main
struct StudySpotsApp: App {

    let modelContainer: ModelContainer = {
        let schema = Schema([StudySpot.self, Review.self, UserProfile.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        guard let container = try? ModelContainer(for: schema, configurations: config) else {
            fatalError("Failed to create ModelContainer.")
        }
        return container
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear(perform: seedIfNeeded)
        }
        .modelContainer(modelContainer)
    }

    private func seedIfNeeded() {
        let context = ModelContext(modelContainer)

        if !UserDefaults.standard.bool(forKey: "hasSeededData") {
            SampleData.seed(into: context)
            try? context.save()
            UserDefaults.standard.set(true, forKey: "hasSeededData")
        }

        if !UserDefaults.standard.bool(forKey: "hasSeededCafes") {
            SampleData.seedCafes(into: context)
            try? context.save()
            UserDefaults.standard.set(true, forKey: "hasSeededCafes")
        }
    }
}
