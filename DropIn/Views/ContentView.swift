import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userState: UserState
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var userLocationManager = UserLocationManager()
    @State private var isListView: Bool = true

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(isListView: $isListView)
                Divider().background(Color.secondary)
                if isListView {
                    ContentListView()
                        .environmentObject(userState)
                } else {
                    ContentGridView()
                        .environmentObject(userState)
                }
            }
            .background(Color("BackgroundColor"))
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    GetLocationManager.shared.loadSavedLocalLocations()
                }
            }
            
            SaveLocationButton()
        }
    }
}
