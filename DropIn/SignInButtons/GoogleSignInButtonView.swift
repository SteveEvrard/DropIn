import SwiftUI

struct GoogleSignInButtonView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: {
            GoogleSignInManager.shared.signIn() { result in
                switch result {
                case .success(let authResult):
                    print("Successfully signed in with Google: \(authResult.user.email ?? "No email")")
                case .failure(let error):
                    print("Failed to sign in with Google: \(error.localizedDescription)")
                }
            }
        }) {
            HStack {
                Image("google-logo")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("Sign in with Google")
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }
}

struct GoogleSignInButtonView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleSignInButtonView().environmentObject(AppState())
    }
}
