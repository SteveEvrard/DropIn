import SwiftUI

struct EmailSignInButtonView: View {
    var body: some View {
        Button(action: {
            // Handle Email Sign-In
        }) {
            HStack {
                Image(systemName: "envelope")
                Text("Sign up with Email")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.buttonColor)
            .foregroundColor(.buttonTextColor)
            .cornerRadius(8)
        }
    }
}

struct SignInWithEmailButton_Previews: PreviewProvider {
    static var previews: some View {
        EmailSignInButtonView()
    }
}
