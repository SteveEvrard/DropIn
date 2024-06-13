import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userState: UserState
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var userLocationManager = UserLocationManager()

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            Divider().background(Color.secondary)
            ContentListView()
                .environmentObject(userState)
        }
        .background(Color("BackgroundColor"))
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                loadSavedLocations()
            }
        }
    }

    private func loadSavedLocations() {
        print("LOAD MAIN APP")
        var didLoad = false
        if let savedLocations = GetLocationManager.shared.getLocations() {
            print("savedLocations: \(savedLocations)")
            for location in savedLocations {
                didLoad = userState.addLocation(location: location)
            }
        }
        if didLoad {
            print("DID")
            GetLocationManager.shared.clearLocations()
        }
    }
}
