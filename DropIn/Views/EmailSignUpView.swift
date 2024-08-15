import SwiftUI

struct EmailSignUpView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @State private var signUpError: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryTextColor"))
            
            HStack {
                TextField("First Name", text: $firstName)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(8)
                
                TextField("Last Name", text: $lastName)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(8)
            }
            
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
            
            if let signUpError = signUpError {
                Text(signUpError)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.top, 8)
            }
            
            VStack(spacing: 16) {
                Button(action: {
                    signUp()
                }) {
                    Text("Sign Up")
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
    
    private func signUp() {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            signUpError = "Please fill in all fields."
            return
        }
        
        EmailSignInManager.shared.signUp(withEmail: email, password: password, firstName: firstName, lastName: lastName) { result in
            switch result {
            case .success:
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                signUpError = error.localizedDescription
            }
        }
    }
}
