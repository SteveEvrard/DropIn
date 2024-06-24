import SwiftUI
import FirebaseAuth

struct HeaderView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isListView: Bool
    @State private var showSignOutAlert = false
    
    var body: some View {
        HStack {
            Button(action: {
                showSignOutAlert = true
            }) {
                Image(systemName: "person.crop.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(Color("ButtonColor"))
                    .font(.title)
            }
            Text("DropIn")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryTextColor"))
            Spacer()
            HStack(spacing: 10) {
                Button(action: {
                    withAnimation {
                        isListView = true
                    }
                }) {
                    Image(systemName: "list.bullet")
                        .imageScale(.large)
                        .foregroundColor(isListView ? Color("ButtonTextColor") : Color("ButtonColor"))
                        .padding(10)
                        .background(isListView ? Color("ButtonColor") : Color.clear)
                        .cornerRadius(8)
                }
                Button(action: {
                    withAnimation {
                        isListView = false
                    }
                }) {
                    Image(systemName: "rectangle.grid.2x2.fill")
                        .imageScale(.large)
                        .foregroundColor(!isListView ? Color("ButtonTextColor") : Color("ButtonColor"))
                        .padding(10)
                        .background(!isListView ? Color("ButtonColor") : Color.clear)
                        .cornerRadius(8)
                }
                .alert(isPresented: $showSignOutAlert) {
                    Alert(
                        title: Text("Sign Out"),
                        message: Text("Are you sure you want to sign out?"),
                        primaryButton: .destructive(Text("Sign Out")) {
                            signOut()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .padding()
        .background(Color("BackgroundColor"))
        .frame(maxWidth: .infinity, alignment: .leading)
        .zIndex(1)
    }
    
    private func signOut() {
        AuthManager.shared.signOut { result in
            switch result {
            case .success():
                appState.updateAuthenticationState()
            case .failure(let error):
                print("Failed to sign out: \(error.localizedDescription)")
            }
        }
    }
}
