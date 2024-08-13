import GoogleSignIn
import Firebase

class GoogleSignInManager: NSObject, ObservableObject {
    static let shared = GoogleSignInManager()
    var appState: AppState?
    
    private override init() {}

    func signIn(completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)

        guard let presentingVC = UIApplication.shared.windows.first?.rootViewController else {
            print("There is no root view controller!")
            return
        }

        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { signInResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = signInResult?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google authentication failed."])))
                return
            }

            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                } else if let authResult = authResult {
                    self.appState?.updateAuthenticationState()
                    self.appState?.displaySiriPopup = true
                    self.saveUserToFirestoreIfNeeded(user: authResult.user) { user in
                        UserState.shared.user = user 
                        completion(.success(authResult))
                    }
                }
            }
        }
    }

    private func saveUserToFirestoreIfNeeded(user: FirebaseAuth.User, completion: @escaping (User) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(user.uid)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                print("User already exists in Firestore")
                do {
                    let existingUser = try document.data(as: User.self)
                    completion(existingUser)
                } catch let error {
                    print("Error decoding user: \(error.localizedDescription)")
                }
            } else {
                // Create a new user document
                let newUser = User(id: user.uid, name: user.displayName ?? "Anonymous", email: user.email ?? "No email", locations: [], categories: [])
                do {
                    try db.collection("users").document(newUser.id).setData(from: newUser) { error in
                        if let error = error {
                            print("Error saving user to Firestore: \(error.localizedDescription)")
                        } else {
                            print("User saved to Firestore successfully")
                            completion(newUser)
                        }
                    }
                } catch let error {
                    print("Error encoding user: \(error.localizedDescription)")
                }
            }
        }
    }
}
