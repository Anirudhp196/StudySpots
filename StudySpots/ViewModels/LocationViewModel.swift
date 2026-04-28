// Tracks the user's GPS location and calculates distances to each spot.
import Observation
internal import CoreLocation

@Observable
final class LocationViewModel: NSObject, CLLocationManagerDelegate {

    var userLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var locationError: String?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func distance(to spot: StudySpot) -> CLLocationDistance? {
        guard let userLocation else { return nil }
        return spot.distance(from: userLocation)
    }

    func formattedDistance(to spot: StudySpot) -> String? {
        guard let meters = distance(to: spot) else { return nil }
        let miles = meters / 1609.34
        if miles < 0.1 {
            let feet = Int(meters * 3.28084)
            return "\(feet) ft"
        }
        return String(format: "%.1f mi", miles)
    }

    func sorted(_ spots: [StudySpot]) -> [StudySpot] {
        guard let userLocation else { return spots }
        return spots.sorted {
            $0.distance(from: userLocation) < $1.distance(from: userLocation)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        userLocation = latest
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationError = nil
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationError = "Location access denied. Enable it in Settings to see nearby spots."
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error.localizedDescription
    }
}
