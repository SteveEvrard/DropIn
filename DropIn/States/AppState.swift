import SwiftUI
import Firebase

class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.isAuthenticated = user != nil
        }
    }

    func updateAuthenticationState() {
        self.isAuthenticated = Auth.auth().currentUser != nil
    }
}
