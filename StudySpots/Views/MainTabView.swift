// Root view with five tabs. Creates the location view model and passes it to every tab.
import SwiftUI
internal import CoreLocation

struct MainTabView: View {

    @State private var locationVM = LocationViewModel()

    var body: some View {
        TabView {
            FeedView()
                .tabItem { Label("Feed", systemImage: "list.bullet.below.rectangle") }

            SpotMapView()
                .tabItem { Label("Map", systemImage: "map.fill") }

            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            LeaderboardView()
                .tabItem { Label("Rankings", systemImage: "trophy.fill") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        .environment(locationVM)
        .onAppear {
            if locationVM.authorizationStatus == .notDetermined {
                locationVM.requestLocationPermission()
            } else {
                locationVM.startUpdatingLocation()
            }
        }
    }
}

#Preview {
    MainTabView()
}
