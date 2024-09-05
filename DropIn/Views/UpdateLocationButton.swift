import SwiftUI
import CoreLocation

struct UpdateLocationButton: View {
    @EnvironmentObject var userState: UserState
    var location: Location

    var body: some View {
        if location.fullAddress == "Unknown" {
            Button(action: {
                updateLocationDetails()
            }) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(Color("ButtonColor"))
                    .background(Color("ButtonBackgroundColor"))
                    .clipShape(Circle())
            }
        }
    }
    
    private func updateLocationDetails() {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        GetLocationManager.shared.fetchLocationDetails(for: clLocation, date: location.date) { newLocation in
            guard var user = userState.user else { return }
            
            if let index = user.locations.firstIndex(where: { $0.id == location.id }) {
                user.locations[index] = newLocation
                userState.saveUser(user: user)
            }
        }
    }
}
