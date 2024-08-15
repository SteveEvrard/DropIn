import Firebase

class EmailSignInManager: NSObject, ObservableObject {
    static let shared = EmailSignInManager()
    var appState: AppState?

    private override init() {}

    func signUp(withEmail email: String, password: String, firstName: String, lastName: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let authResult = authResult {
                self.appState?.updateAuthenticationState()
                self.appState?.displaySiriPopup = true
                let fullName = "\(firstName) \(lastName)"
                self.saveUserToFirestore(user: authResult.user, fullName: fullName, email: email) { user in
                    UserState.shared.user = user
                    completion(.success(authResult))
                }
            }
        }
    }

    func signIn(withEmail email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let authResult = authResult {
                self.appState?.updateAuthenticationState()
                self.fetchUserFromFirestore(user: authResult.user) { user in
                    UserState.shared.user = user
                    completion(.success(authResult))
                }
            }
        }
    }

    private func saveUserToFirestore(user: FirebaseAuth.User, fullName: String, email: String, completion: @escaping (User) -> Void) {
        let db = Firestore.firestore()
        let newUser = User(id: user.uid, name: fullName, email: email, locations: [], categories: [])

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

    private func fetchUserFromFirestore(user: FirebaseAuth.User, completion: @escaping (User) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(user.uid)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let existingUser = try document.data(as: User.self)
                    completion(existingUser)
                } catch let error {
                    print("Error decoding user: \(error.localizedDescription)")
                }
            } else {
                print("User document does not exist in Firestore")
                // Optionally, you could create a new user here if the document doesn't exist
            }
        }
    }
}
