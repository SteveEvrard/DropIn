//
//  LocationManager.swift
//  DropIn
//
//  Created by Stephen Evrard on 5/14/24.
//

import CoreLocation

class UserLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var userLocationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var locationAccessGranted: Bool = false

    override init() {
        super.init()
        userLocationManager.delegate = self
        userLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationAccess() {
        print("request")
        userLocationManager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation() async -> CLLocation? {
        userLocationManager.startUpdatingLocation()

        return await withCheckedContinuation { continuation in
            if let location = userLocationManager.location {
                continuation.resume(returning: location)
            } else {
                continuation.resume(returning: nil)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
            userLocationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationAccessGranted = status == .authorizedWhenInUse || status == .authorizedAlways
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
