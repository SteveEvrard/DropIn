import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var appState: AppState
    @StateObject var userState = UserState.shared

    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            Divider().background(Color.secondary)
            ContentListView()
                .environmentObject(userState)
        }
        .background(Color("BackgroundColor"))
        .onAppear {
            if let userId = Auth.auth().currentUser?.uid {
                userState.fetchUser(userId: userId)
            }
        }
    }
}
