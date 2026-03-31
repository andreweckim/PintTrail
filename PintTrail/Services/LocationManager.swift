import CoreLocation
import MapKit

@MainActor
@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentVenueName: String?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        manager.requestLocation()
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            currentLocation = location
            lookUpVenue(at: location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                requestLocation()
            }
        }
    }

    private func lookUpVenue(at location: CLLocation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "bar pub brewery restaurant"
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 100,
            longitudinalMeters: 100
        )

        let search = MKLocalSearch(request: request)
        Task {
            let response = try? await search.start()
            if let item = response?.mapItems.first {
                currentVenueName = item.name
            }
        }
    }
}
