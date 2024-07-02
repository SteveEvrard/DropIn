import SwiftUI

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(Color("ButtonTextColor"))
            .padding()
            .background(Color("Success"))
            .cornerRadius(10)
            .transition(.move(edge: .top))
            .animation(.easeInOut, value: UUID())
    }
}
