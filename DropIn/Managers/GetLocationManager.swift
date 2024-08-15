import Foundation
import CoreLocation
import FirebaseAuth

class GetLocationManager {
    static let shared = GetLocationManager()
    private init() {}

    static let locationsKey = "savedLocations"

    func saveLocationToLocalStorage(latitude: Double, longitude: Double) {
        let locationCoordinates = CLLocation(latitude: latitude, longitude: longitude)
        fetchLocationDetails(for: locationCoordinates) { [weak self] newLocation in
            guard let self = self else { return }
            var savedLocations = self.getLocations() ?? []
            savedLocations.append(newLocation)
            self.saveLocationsToUserDefaults(savedLocations)
        }
    }

    func fetchLocationDetails(for location: CLLocation, completion: @escaping (Location) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            let (fullAddress, streetAddress, cityState, zipCode, defaultName) = self.formatLocationDetails(from: placemarks, error: error)
            let newLocation = Location(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                date: Date(),
                name: defaultName ?? "Unknown",
                fullAddress: fullAddress ?? "Unknown",
                streetAddress: streetAddress ?? "Unknown",
                cityState: cityState ?? "Unknown",
                zipCode: zipCode ?? "Unknown"
            )
            completion(newLocation)
        }
    }

    private func formatLocationDetails(from placemarks: [CLPlacemark]?, error: Error?) -> (String?, String?, String?, String?, String?) {
        guard let placemark = placemarks?.first, error == nil else {
            return (nil, nil, nil, nil, nil)
        }

        let fullAddress = formatAddress(from: placemark)
        let streetAddress = formatStreetAddress(from: placemark)
        let city = placemark.locality ?? ""
        let state = placemark.administrativeArea ?? ""
        let cityState = "\(city), \(state)"
        let zipCode = placemark.postalCode
        let defaultName = streetAddress == "" ? "N/A" : streetAddress

        return (fullAddress, streetAddress, cityState, zipCode, defaultName)
    }

    private func saveLocationsToUserDefaults(_ locations: [Location]) {
        if let data = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(data, forKey: Self.locationsKey)
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
        return addressString != "" ? addressString.trimmingCharacters(in: .whitespacesAndNewlines) : "N/A"
    }
    
    func formatStreetAddress(from placemark: CLPlacemark) -> String {
        var streetAddress = ""
        if let subThoroughfare = placemark.subThoroughfare {
            streetAddress += subThoroughfare + " "
        }
        if let thoroughfare = placemark.thoroughfare {
            streetAddress += thoroughfare
        }
        return streetAddress != "" ? streetAddress.trimmingCharacters(in: .whitespacesAndNewlines) : "N/A"
    }

    func loadSavedLocalLocations() {
        var allLocationsAdded = true
        if let savedLocations = getLocations() {
            for location in savedLocations {
                let didAddLocation = UserState.shared.addLocation(location: location)
                if !didAddLocation {
                    allLocationsAdded = false
                }
            }
        }
        if allLocationsAdded {
            clearLocations()
        }
    }
}
