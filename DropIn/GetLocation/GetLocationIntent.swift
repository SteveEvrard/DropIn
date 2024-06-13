//
//  GetLocationIntent.swift
//  DropIn
//
//  Created by Stephen Evrard on 5/9/24.
//
import AppIntents
import CoreLocation

struct GetLocationIntent: AppIntent {
    static let title = LocalizedStringResource("Get Location")

    func perform() async throws -> some ProvidesDialog {
        let locationManager = LocationManager()
        guard let location = await locationManager.getCurrentLocation() else {
            return .result(dialog: "Failed to get location.")
        }

        UserDefaultsManager.saveLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, name: "Placeholder, PA")

        return .result(dialog: "Location saved successfully!")
    }
}
