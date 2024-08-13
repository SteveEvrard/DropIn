import SwiftUI
import FirebaseAuth

struct HeaderView: View {
    @EnvironmentObject var appState: AppState
    @Binding var isListView: Bool
    @State private var showSignOutAlert = false

    var body: some View {
        HStack {
            Button(action: {
                showSignOutAlert = true
            }) {
                Image(systemName: "person.crop.circle.fill")
                    .imageScale(.medium)
                    .foregroundColor(Color("ButtonColor"))
                    .font(.title2)
            }
            Text("DropIn")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("PrimaryTextColor"))
            Spacer()
            if isListView {
                SaveKMLButton {
                    appState.isSelectable.toggle()
                }
                .padding(.trailing, 8)
            }
            HStack(spacing: 0) {
                Button(action: {
                    isListView = true
                }) {
                    Image(systemName: "list.bullet")
                        .imageScale(.medium)
                        .foregroundColor(isListView ? Color("ButtonTextColor") : Color("ButtonColor"))
                        .padding(8)
                        .background(isListView ? Color("ButtonColor") : Color.clear)
                        .cornerRadius(isListView ? 8 : 0)
                        .cornerRadius(isListView ? 8 : 0, corners: [.topLeft, .bottomLeft])
                }
                .alert(isPresented: $showSignOutAlert) {
                    Alert(
                        title: Text("Sign Out"),
                        message: Text("Are you sure you want to sign out?"),
                        primaryButton: .destructive(Text("Sign Out")) {
                            signOut()
                        },
                        secondaryButton: .cancel()
                    )
                }
                Button(action: {
                    isListView = false
                    appState.isSelectable = false
                }) {
                    Image(systemName: "rectangle.grid.2x2.fill")
                        .imageScale(.medium)
                        .foregroundColor(!isListView ? Color("ButtonTextColor") : Color("ButtonColor"))
                        .padding(8)
                        .background(!isListView ? Color("ButtonColor") : Color.clear)
                        .cornerRadius(!isListView ? 8 : 0)
                        .cornerRadius(!isListView ? 8 : 0, corners: [.topRight, .bottomRight])
                }
            }
            .background(Color("ButtonColor").opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color("BackgroundColor"))
        .frame(maxWidth: .infinity, alignment: .leading)
        .zIndex(1)
    }
    
    private func signOut() {
        AuthManager.shared.signOut { result in
            switch result {
            case .success():
                appState.updateAuthenticationState()
            case .failure(let error):
                print("Failed to sign out: \(error.localizedDescription)")
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
