import AppIntents
import CoreLocation
import SwiftUI

struct GetLocationIntent: AppIntent {
    static let title = LocalizedStringResource("Get Location")
    
    var userState: UserState {
        return UserState.shared
    }

    func perform() async throws -> some ProvidesDialog {
        let userLocationManager = UserLocationManager()
        guard let location = await userLocationManager.getCurrentLocation() else {
            return .result(dialog: "Failed to get location.")
        }

        // Always save to local storage
        saveLocationToLocalStorage(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, name: "Placeholder, PA")

        return .result(dialog: "Location saved successfully!")
    }

    private func saveLocationToLocalStorage(latitude: Double, longitude: Double, name: String) {
        let locationCoordinates = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locationCoordinates) { placemarks, error in
            var address: String? = nil
            if let placemark = placemarks?.first, error == nil {
                address = self.formatAddress(from: placemark)
            }

            let newLocation = Location(latitude: latitude, longitude: longitude, date: Date(), name: name, address: address, cityState: nil)
            var savedLocations = self.getSavedLocations() ?? []
            savedLocations.append(newLocation)
            self.saveLocationsToUserDefaults(savedLocations)
        }
    }

    private func getSavedLocations() -> [Location]? {
        if let data = UserDefaults.standard.data(forKey: "savedLocations"),
           let locations = try? JSONDecoder().decode([Location].self, from: data) {
            return locations
        } else {
            return nil
        }
    }

    private func saveLocationsToUserDefaults(_ locations: [Location]) {
        if let data = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(data, forKey: "savedLocations")
        }
    }

    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressString = ""
        if let subThoroughfare = placemark.subThoroughfare {
            addressString += subThoroughfare + " "
        }
        if let thoroughfare = placemark.thoroughfare {
            addressString += thoroughfare + ", "
        }
        if let locality = placemark.locality {
            addressString += locality + ", "
        }
        if let administrativeArea = placemark.administrativeArea {
            addressString += administrativeArea + " "
        }
        if let postalCode = placemark.postalCode {
            addressString += postalCode + " "
        }
        if let country = placemark.country {
            addressString += country
        }
        return addressString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
