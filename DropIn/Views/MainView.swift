import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userState: UserState

    var body: some View {
        if appState.isAuthenticated {
            ContentView()
                .environmentObject(userState)
        } else {
            SignInView()
        }
    }
}
