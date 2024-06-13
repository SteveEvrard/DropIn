import Foundation
import CoreLocation
import FirebaseAuth

class GetLocationManager {
    static let shared = GetLocationManager()
    private init() {} // Private initializer for singleton

    static let locationsKey = "savedLocations"

    func saveLocation(latitude: Double, longitude: Double, name: String, cityState: String? = nil) {
        let locationCoordinates = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(locationCoordinates) { placemarks, error in
            var address: String? = nil
            if let placemark = placemarks?.first, error == nil {
                address = Self.formatAddress(from: placemark)
            }

            let newLocation = Location(latitude: latitude, longitude: longitude, date: Date(), name: name, address: address, cityState: cityState)
            UserState.shared.addLocation(location: newLocation)
        }
    }

    func getLocations() -> [Location]? {
        if let data = UserDefaults.standard.data(forKey: Self.locationsKey),
           let locations = try? JSONDecoder().decode([Location].self, from: data) {
            print("GET LOCATIONS: \(locations)")
            return locations
        } else {
            print("GET LOCATIONS: NONE")
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
                    locations[index].address = Self.formatAddress(from: placemark)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
//            Self.saveLocations(locations)
            completion(locations)
        }
    }

    private static func saveLocations(_ locations: [Location]) {
        if let data = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(data, forKey: Self.locationsKey)
        }
    }

    private static func formatAddress(from placemark: CLPlacemark) -> String {
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
