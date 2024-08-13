import AuthenticationServices
import FirebaseAuth
import Firebase

class AppleSignInManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static let shared = AppleSignInManager()
    var appState: AppState?

    func startSignInWithAppleFlow(completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow }!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = AppleSignInManager.shared.currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Error authenticating: \(error.localizedDescription)")
                    return
                }
                guard let authResult = authResult else { return }
                self.handleSuccessfulSignIn(authResult: authResult, appleIDCredential: appleIDCredential) { user in
                    UserState.shared.user = user // Set the user in the singleton instance
                    self.appState?.updateAuthenticationState()
                    self.appState?.displaySiriPopup = true
                    print("Successfully signed in with Apple!")
                }
            }
        }
    }

    private func handleSuccessfulSignIn(authResult: AuthDataResult, appleIDCredential: ASAuthorizationAppleIDCredential, completion: @escaping (User) -> Void) {
        let db = Firestore.firestore()
        let user = authResult.user
        let usersRef = db.collection("users").document(user.uid)

        usersRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("User already exists in Firestore.")
                do {
                    let existingUser = try document.data(as: User.self)
                    completion(existingUser)
                } catch let error {
                    print("Error decoding user: \(error.localizedDescription)")
                }
            } else {
                // Create a new user in Firestore
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                let userData: [String: Any] = [
                    "uid": user.uid,
                    "email": email ?? "",
                    "displayName": "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")",
                    "locations": []
                ]
                usersRef.setData(userData) { error in
                    if let error = error {
                        print("Error saving user to Firestore: \(error.localizedDescription)")
                    } else {
                        print("User saved to Firestore.")
                        let newUser = User(id: user.uid, name: "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")", email: email ?? "", locations: [], categories: [])
                        completion(newUser)
                    }
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }

    var currentNonce: String?
}
