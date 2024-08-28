import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class UserManager {
    private let db = Firestore.firestore()

    func fetchUser(userId: String) -> AnyPublisher<User, Error> {
        Future { promise in
            let docRef = self.db.collection("users").document(userId)
            docRef.getDocument { document, error in
                if let error = error {
                    promise(.failure(error))
                } else if let document = document, document.exists {
                    do {
                        let user = try document.data(as: User.self)
                        promise(.success(user))
                    } catch let error {
                        promise(.failure(error))
                    }
                } else {
                    promise(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func saveUser(user: User) -> AnyPublisher<Void, Error> {
        Future { promise in
            do {
                try self.db.collection("users").document(user.id).setData(from: user) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch let error {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func updateUser(userId: String, data: [String: Any]) -> AnyPublisher<Void, Error> {
        Future { promise in
            let docRef = self.db.collection("users").document(userId)
            docRef.updateData(data) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteUser(userId: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            let docRef = self.db.collection("users").document(userId)
            docRef.delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
