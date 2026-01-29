import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        if appState.isAuthenticated {
            if subscriptionManager.isLoading {
                ZStack {
                    Color("BackgroundColor").ignoresSafeArea()
                    ProgressView()
                }
            } else if subscriptionManager.hasActiveEntitlement {
                ContentView()
                    .environmentObject(userState)
            } else {
                PaywallView()
            }
        } else {
            SignInView()
        }
    }
}
