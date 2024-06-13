import SwiftUI
import Firebase
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }

    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct DropInApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()
    @StateObject private var userState = UserState.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .environmentObject(userState)
                .onAppear {
                    GoogleSignInManager.shared.appState = appState
                    AppleSignInManager.shared.appState = appState
//                    if let userId = Auth.auth().currentUser?.uid {
//                        userState.fetchUser(userId: userId) {
//                            loadSavedLocations()
//                        }
//                    }
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
