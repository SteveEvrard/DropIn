import AppIntents
import CoreLocation
import SwiftUI
import FirebaseCore
import FirebaseAuth

struct GetLocationIntent: AppIntent {
    static let title = LocalizedStringResource("Get Location")
    
    var userState: UserState {
        return UserState.shared
    }

    func perform() async throws -> some ProvidesDialog {
        // AppIntents may run before the main app finished launching.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        guard Auth.auth().currentUser != nil else {
            return .result(dialog: "Please open DropIn and sign in to use this shortcut.")
        }
        
        let entitled = await SubscriptionEntitlementChecker.isEntitledNow()
        guard entitled else {
            return .result(dialog: "A DropIn subscription is required. Open the app to start your 7‑day free trial.")
        }
        
        let userLocationManager = UserLocationManager()
        guard let location = await userLocationManager.getCurrentLocation() else {
            return .result(dialog: "Failed to get location.")
        }

        GetLocationManager.shared.saveLocationToLocalStorage(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

        return .result(dialog: "Location saved successfully!")
    }
}
