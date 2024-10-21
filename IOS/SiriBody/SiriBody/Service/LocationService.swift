import CoreLocation
import Combine

class LocationService: NSObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()

    let locationSubject = PassthroughSubject<CLLocation, Never>()

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        self.locationSubject.send(newLocation)
    }
}
