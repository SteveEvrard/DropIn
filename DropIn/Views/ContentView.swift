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
                GetLocationManager.shared.loadSavedLocalLocations()
            }
        }
    }
}
