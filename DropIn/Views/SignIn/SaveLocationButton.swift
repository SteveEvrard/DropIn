import SwiftUI
import CoreLocation

struct SaveLocationButton: View {
    @State private var showToast: Bool = false
    
    var body: some View {
        ZStack {
            Button(action: {
                fetchAndSaveLocation()
            }) {
                Image(systemName: "scope")
                    .font(.system(size: 24))
                    .foregroundColor(Color("ButtonTextColor"))
                    .padding()
                    .background(Color("ButtonColor"))
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            .padding()
            .position(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.height - 125)
            
            if showToast {
                VStack {
                    ToastView(message: "Location saved successfully!")
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showToast = false
                                }
                            }
                        }
                    Spacer()
                }
            }
        }
    }

    private func fetchAndSaveLocation() {
        Task {
            let userLocationManager = UserLocationManager()
            guard let location = await userLocationManager.getCurrentLocation() else {
                print("Failed to get location.")
                return
            }

            GetLocationManager.shared.fetchLocationDetails(for: location) { newLocation in
                let didAddLocation = UserState.shared.addLocation(location: newLocation)
                if didAddLocation {
                    GetLocationManager.shared.clearLocations()
                    withAnimation {
                        showToast = true
                    }
                }
            }
        }
    }
}
