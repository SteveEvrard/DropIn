import SwiftUI

struct LocationListItem: View {
    @EnvironmentObject var userState: UserState
    var location: Location
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @State private var showAlert = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(location.address ?? "Unknown Address")
                            .foregroundColor(Color("PrimaryTextColor"))
                        if let cityState = location.cityState {
                            Text(cityState)
                                .font(.subheadline)
                                .foregroundColor(Color("SecondaryTextColor"))
                        }
                    }
                    Spacer()
                    Button(action: {
                        openInMaps(address: location.address ?? "")
                    }) {
                        Image(systemName: "map.fill")
                            .foregroundColor(Color("ButtonColor"))
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
                .background(Color("BackgroundColor"))
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.width < 0 {
                                self.offset = gesture.translation.width
                            }
                        }
                        .onEnded { _ in
                            withAnimation {
                                if -self.offset > 100 {
                                    self.isSwiped = true
                                    self.offset = -100
                                } else {
                                    self.isSwiped = false
                                    self.offset = 0
                                }
                            }
                        }
                )
                Divider()
            }
            
            if isSwiped {
                HStack {
                    Spacer()
                    Button(action: {
                        self.showAlert = true
                    }) {
                        Text("Delete")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.red)
                    }
                    .frame(width: 100, height: 50)
                    .background(Color.red)
                }
                .frame(height: 50)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Location"),
                message: Text("Are you sure you want to delete this location?"),
                primaryButton: .destructive(Text("Delete")) {
                    withAnimation {
                        self.deleteLocation()
                    }
                },
                secondaryButton: .cancel() {
                    withAnimation {
                        self.offset = 0
                        self.isSwiped = false
                    }
                }
            )
        }
    }
    
    private func openInMaps(address: String) {
        let urlString = "http://maps.apple.com/?q=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func deleteLocation() {
        if let user = userState.user {
            userState.removeLocation(locationId: location.id)
            self.offset = 0
            self.isSwiped = false
        }
    }
}

struct LocationListItem_Previews: PreviewProvider {
    static var previews: some View {
        LocationListItem(location: Location(id: UUID(), latitude: 0.0, longitude: 0.0, date: Date(), name: "Sample Location", address: "Sample Address", cityState: "Sample City, State"))
            .environmentObject(UserState.shared)
    }
}
