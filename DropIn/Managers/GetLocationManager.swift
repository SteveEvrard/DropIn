import Foundation
import CoreLocation
import FirebaseAuth

class GetLocationManager {
    static let shared = GetLocationManager()
    private init() {} // Private initializer for singleton

    static let locationsKey = "savedLocations"

    func saveLocationToLocalStorage(latitude: Double, longitude: Double) {
        let locationCoordinates = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locationCoordinates) { placemarks, error in
            var fullAddress: String? = nil
            var streetAddress: String? = nil
            var cityState: String? = nil
            var zipCode: String? = nil
            var defaultName: String? = nil
            if let placemark = placemarks?.first, error == nil {
                fullAddress = self.formatAddress(from: placemark)
                streetAddress = self.formatStreetAddress(from: placemark)
                zipCode = placemark.postalCode
                defaultName = streetAddress
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                cityState = "\(city), \(state)"
            }

            let newLocation = Location(
                latitude: latitude,
                longitude: longitude,
                date: Date(),
                name: defaultName ?? "Unknown",
                fullAddress: fullAddress ?? "Unknown",
                streetAddress: streetAddress ?? "Unknown",
                cityState: cityState ?? "Unknown",
                zipCode: zipCode ?? "Unknown"
            )
            var savedLocations = self.getLocations() ?? []
            savedLocations.append(newLocation)
            self.saveLocationsToUserDefaults(savedLocations)
        }
    }

    private func saveLocationsToUserDefaults(_ locations: [Location]) {
        if let data = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(data, forKey: GetLocationManager.locationsKey)
        }
    }
    
    func getLocations() -> [Location]? {
        if let data = UserDefaults.standard.data(forKey: Self.locationsKey),
           let locations = try? JSONDecoder().decode([Location].self, from: data) {
            return locations
        } else {
            return nil
        }
    }

    func clearLocations() {
        UserDefaults.standard.removeObject(forKey: Self.locationsKey)
    }

    func updateCityStateForLocations(completion: @escaping ([Location]) -> Void) {
        print("updateCityStateForLocations")
        guard var locations = getLocations() else { return }
        let geocoder = CLGeocoder()
        let group = DispatchGroup()

        for index in locations.indices {
            let location = locations[index]
            let locationCoordinates = CLLocation(latitude: location.latitude, longitude: location.longitude)
            group.enter()
            geocoder.reverseGeocodeLocation(locationCoordinates) { placemarks, error in
                if let placemark = placemarks?.first, error == nil {
                    let city = placemark.locality ?? ""
                    let state = placemark.administrativeArea ?? ""
                    locations[index].cityState = "\(city), \(state)"
                    locations[index].fullAddress = self.formatAddress(from: placemark)
                    locations[index].streetAddress = self.formatStreetAddress(from: placemark)
                    locations[index].zipCode = placemark.postalCode ?? "Unknown"
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(locations)
        }
    }

    private static func saveLocations(_ locations: [Location]) {
        if let data = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(data, forKey: Self.locationsKey)
        }
    }

    func formatAddress(from placemark: CLPlacemark) -> String {
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
    
    func formatStreetAddress(from placemark: CLPlacemark) -> String {
        var streetAddress = ""
        if let subThoroughfare = placemark.subThoroughfare {
            streetAddress += subThoroughfare + " "
        }
        if let thoroughfare = placemark.thoroughfare {
            streetAddress += thoroughfare
        }
        return streetAddress.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func loadSavedLocalLocations() {
        var didLoad = false
        if let savedLocations = GetLocationManager.shared.getLocations() {
            for location in savedLocations {
                didLoad = UserState.shared.addLocation(location: location)
            }
        }
        if didLoad {
            GetLocationManager.shared.clearLocations()
        }
    }
}
