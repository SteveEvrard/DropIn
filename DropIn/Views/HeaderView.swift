import SwiftUI
import FirebaseAuth

struct HeaderView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse.circle.fill")
                .imageScale(.large)
                .foregroundColor(Color("ButtonColor"))
            Text("DropIn")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryTextColor"))
            Spacer()
            Button(action: {
                AuthManager.shared.signOut { result in
                    switch result {
                    case .success():
                        appState.updateAuthenticationState()
                    case .failure(let error):
                        print("Failed to sign out: \(error.localizedDescription)")
                    }
                }
            }) {
                Text("Sign Out")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color("BackgroundColor"))
        .frame(maxWidth: .infinity, alignment: .leading)
        .zIndex(1)
    }
}
