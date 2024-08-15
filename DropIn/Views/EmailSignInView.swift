import SwiftUI

struct EmailSignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var signInError: String? = nil
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Log In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryTextColor"))
            
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray)
                .cornerRadius(8)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            ZStack(alignment: .trailing) {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(8)
                } else {
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(Color("PrimaryTextColor"))
                        .padding(.trailing, 10)
                }
            }
            
            if let signInError = signInError {
                Text(signInError)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.top, 8)
            }
            
            Button(action: {
                // Navigate to forgot password view
            }) {
                Text("Forgot Password?")
                    .foregroundColor(.accentColor)
                    .underline()
            }
            .padding(.top, 5)
            
            VStack(spacing: 16) {
                Button(action: {
                    signIn()
                }) {
                    Text("Log In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("ButtonColor"))
                        .foregroundColor(.buttonTextColor)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Go Back")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }
            }
            .padding(.top, 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding()
    }
    
    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            signInError = "Please fill in all fields."
            return
        }
        
        EmailSignInManager.shared.signIn(withEmail: email, password: password) { result in
            switch result {
            case .success:
                // Handle success, e.g., dismiss the view or show a success message
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                // Handle error
                signInError = error.localizedDescription
            }
        }
    }
}
