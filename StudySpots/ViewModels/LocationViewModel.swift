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

    /// Returns the distance in meters from the user to a study spot, or nil if location is unavailable.
    func distance(to spot: StudySpot) -> CLLocationDistance? {
        guard let userLocation else { return nil }
        return spot.distance(from: userLocation)
    }

    /// Human-readable distance string (e.g. "0.3 mi").
    func formattedDistance(to spot: StudySpot) -> String? {
        guard let meters = distance(to: spot) else { return nil }
        let miles = meters / 1609.34
        if miles < 0.1 {
            let feet = Int(meters * 3.28084)
            return "\(feet) ft"
        }
        return String(format: "%.1f mi", miles)
    }

    /// Spots sorted by distance from user. Falls back to original order if location is unavailable.
    func sorted(_ spots: [StudySpot]) -> [StudySpot] {
        guard let userLocation else { return spots }
        return spots.sorted {
            $0.distance(from: userLocation) < $1.distance(from: userLocation)
        }
    }

    // MARK: - CLLocationManagerDelegate

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
