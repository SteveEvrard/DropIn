import SwiftUI

struct SignInView: View {
    @State private var showEmailSignIn = false

    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "mappin.and.ellipse.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.buttonColor)
                .padding(.bottom, 10)
            
            Text("DropIn")
                .font(.largeTitle)
                .foregroundColor(.primaryTextColor)
                .padding(.bottom, 5)
            
            SignInButtonView()
            
            Spacer()
            
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.secondaryTextColor)
                Button(action: {
                    showEmailSignIn = true
                }) {
                    Text("Log in")
                        .foregroundColor(.accentColor)
                        .underline()
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInView()
        }
    }
}
