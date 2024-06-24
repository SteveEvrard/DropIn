import Foundation
import Combine
import Firebase

class UserState: ObservableObject {
    static let shared = UserState() // Singleton instance
    
    @Published var user: User?

    private let userManager = UserManager()
    private var cancellables = Set<AnyCancellable>()

    private init() {
        if let userId = Auth.auth().currentUser?.uid {
            fetchUser(userId: userId)
        }
    }

    func fetchUser(userId: String) {
        userManager.fetchUser(userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching user: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { user in
                self.user = user
                self.uploadSavedLocations()
            })
            .store(in: &cancellables)
    }

    func saveUser(user: User) {
        userManager.saveUser(user: user)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error saving user: \(error.localizedDescription)")
                    break
                case .finished:
                    self.user = user
                    break
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func updateUser(userId: String, data: [String: Any]) {
        userManager.updateUser(userId: userId, data: data)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error updating user: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func addLocation(location: Location) -> Bool {
        guard var user = user else { return false }
        user.locations.append(location)
        saveUser(user: user)
        return true
    }

    func removeLocation(locationId: UUID) {
        guard var user = user else { return }
        user.locations.removeAll { $0.id == locationId }
        saveUser(user: user)
    }

    func uploadSavedLocations() {
        guard let locations = GetLocationManager.shared.getLocations() else { return }

        for location in locations {
            addLocation(location: location)
        }
        
        UserDefaults.standard.removeObject(forKey: "savedLocations")
    }

    func checkAndUpdateFromLocalStorage() {
        self.uploadSavedLocations()
    }
}
