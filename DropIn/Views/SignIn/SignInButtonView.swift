import SwiftUI

struct SignInButtonView: View {
    var body: some View {
        VStack(spacing: 16) {
            GoogleSignInButtonView()
            AppleSignInButtonView()
            EmailSignInButtonView()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}

struct SignInButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SignInButtonView()
    }
}
