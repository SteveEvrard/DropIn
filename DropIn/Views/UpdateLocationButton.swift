import SwiftUI
import CoreLocation

struct UpdateLocationButton: View {
    var location: Location
    var onUpdate: () -> Void

    var body: some View {
        if location.fullAddress == "Unknown" {
            Button(action: onUpdate) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(Color("ButtonColor"))
                    .padding(10)
                    .background(Color("ButtonBackgroundColor"))
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
        }
    }
}
