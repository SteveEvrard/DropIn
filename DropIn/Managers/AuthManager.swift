import Firebase
import Combine

class AuthManager {
    static let shared = AuthManager()

    private init() {}

    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let signOutError as NSError {
            completion(.failure(signOutError))
        }
    }

    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No current user."])))
            return
        }

        let userManager = UserManager()

        userManager.deleteUser(userId: user.uid)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    user.delete { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { _ in })
            .store(in: &UserState.shared.cancellables)
    }
}
