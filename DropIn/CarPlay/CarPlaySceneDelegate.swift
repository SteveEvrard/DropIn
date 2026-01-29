import CarPlay
import UIKit
import FirebaseAuth

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?
    var window: UIWindow?

    // MARK: - Scene Connection

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController

        // Set up and configure the initial grid template
        let gridTemplate = createGridTemplate()
        setRootTemplate(gridTemplate)
    }

    // MARK: - Creating Templates

    /// Creates the main grid template for CarPlay with a save location button.
    private func createGridTemplate() -> CPGridTemplate {
        // Create the save location button
        let saveLocationButton = CPGridButton(titleVariants: ["Save Location"], image: UIImage(systemName: "scope")!) { [weak self] button in
            self?.handleSaveLocation()
        }

        // Create the grid template with the button
        let gridTemplate = CPGridTemplate(title: "DropIn", gridButtons: [saveLocationButton])
        return gridTemplate
    }

    // MARK: - Save Location Handling

    /// Handles the action of saving the current location.
    private func handleSaveLocation() {
        Task { @MainActor in
            guard Auth.auth().currentUser != nil else {
                showMessage(title: "Sign in required", message: "Open DropIn on your iPhone and sign in to save locations.")
                return
            }
            
            let entitled = await SubscriptionEntitlementChecker.isEntitledNow()
            guard entitled else {
                showMessage(title: "Subscription required", message: "A DropIn subscription is required. Open the app to start your 7‑day free trial.")
                return
            }
            
            // Implement the location saving logic directly, similar to the SaveLocationButton
            fetchAndSaveLocation()
        }
    }

    /// Fetches the current location and saves it.
    private func fetchAndSaveLocation() {
        Task {
            let userLocationManager = UserLocationManager()
            guard let location = await userLocationManager.getCurrentLocation() else {
                print("Failed to get location.")
                return
            }

            GetLocationManager.shared.fetchLocationDetails(for: location) { newLocation in
                let didAddLocation = UserState.shared.addLocation(location: newLocation)
                if didAddLocation {
                    GetLocationManager.shared.clearLocations()
                    print("Location saved successfully!")
                } else {
                    print("Failed to save location.")
                }
            }
        }
    }

    // MARK: - Setting Root Template

    /// Sets the root template with a completion handler for better control.
    private func setRootTemplate(_ template: CPTemplate) {
        interfaceController?.setRootTemplate(template, animated: true, completion: { success, error in
            if success {
                print("Successfully set root template.")
            } else if let error = error {
                print("Failed to set root template: \(error.localizedDescription)")
            }
        })
    }
    
    private func showMessage(title: String, message: String) {
        let action = CPAlertAction(title: "OK", style: .default) { _ in }
        let combinedTitle = "\(title)\n\(message)"
        let alert = CPAlertTemplate(titleVariants: [combinedTitle], actions: [action])
        interfaceController?.presentTemplate(alert, animated: true, completion: nil)
    }
}
