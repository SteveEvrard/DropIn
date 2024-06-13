import SwiftUI
import AuthenticationServices

struct AppleSignInButtonView: View {
    var body: some View {
        SignInWithAppleButton(
            onRequest: { request in
                let nonce = randomNonceString()
                AppleSignInManager.shared.currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = sha256(nonce)
            },
            onCompletion: { result in
                switch result {
                case .success(let authResults):
                    AppleSignInManager.shared.authorizationController(controller: ASAuthorizationController(authorizationRequests: [ASAuthorizationAppleIDProvider().createRequest()]), didCompleteWithAuthorization: authResults)
                case .failure(let error):
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .cornerRadius(8)
    }
}

struct SignInWithAppleButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AppleSignInButtonView()
    }
}
