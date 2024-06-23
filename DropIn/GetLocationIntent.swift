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

        GetLocationManager.shared.saveLocationToLocalStorage(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

        return .result(dialog: "Location saved successfully!")
    }
}
