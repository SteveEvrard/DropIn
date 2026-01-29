import SwiftUI
import Firebase

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.presentationMode) var presentationMode

    @State private var showAlert = false
    @State private var isDeletingAccount = false
    @State private var isRestoringPurchases = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("PrimaryTextColor"))
                
                VStack(spacing: 12) {
                    Button(action: {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Manage Subscription")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("ButtonColor").opacity(0.15))
                            .foregroundColor(Color("ButtonColor"))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isRestoringPurchases = true
                        Task {
                            await subscriptionManager.restorePurchases()
                            isRestoringPurchases = false
                        }
                    }) {
                        Text(isRestoringPurchases ? "Restoring..." : "Restore Purchases")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("ButtonColor").opacity(0.15))
                            .foregroundColor(Color("ButtonColor"))
                            .cornerRadius(8)
                    }
                    .disabled(isRestoringPurchases)
                    
                    Text(subscriptionManager.hasActiveEntitlement ? "Subscription: Active" : "Subscription: Inactive")
                        .foregroundColor(Color("SecondaryTextColor"))
                        .font(.subheadline)
                }

                Button(action: {
                    signOut()
                }) {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("ButtonColor"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    showAlert = true
                }) {
                    Text("Delete Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete"), action: deleteAccount),
                        secondaryButton: .cancel()
                    )
                }
            }
            .padding()
            .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color("PrimaryTextColor"))
            })
            .disabled(isDeletingAccount)
        }
    }

    private func signOut() {
        AuthManager.shared.signOut { result in
            switch result {
            case .success:
                appState.updateAuthenticationState()
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Error signing out: \(error.localizedDescription)")
            }
        }
    }

    private func deleteAccount() {
        isDeletingAccount = true
        AuthManager.shared.deleteAccount { result in
            switch result {
            case .success:
                appState.updateAuthenticationState()
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Error deleting account: \(error.localizedDescription)")
            }
            isDeletingAccount = false
        }
    }
}
