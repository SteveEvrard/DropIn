import SwiftUI

struct EmailSignInButtonView: View {
    @State private var showSignUp = false
    
    var body: some View {
        Button(action: {
            showSignUp.toggle()
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
        .sheet(isPresented: $showSignUp) {
            EmailSignUpView()
        }
    }
}
