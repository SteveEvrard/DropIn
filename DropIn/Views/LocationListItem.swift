import SwiftUI

struct LocationListItem: View {
    @EnvironmentObject var userState: UserState
    var location: Location
    @Binding var showEditNamePopup: Location?
    @Binding var editedLocationName: String
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @State private var showAlert = false
    @State private var isExpanded = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(location.name)
                                .foregroundColor(Color("PrimaryTextColor"))
                            Text(location.cityState)
                                .font(.subheadline)
                                .foregroundColor(Color("SecondaryTextColor"))
                        }
                        Spacer()
                        Button(action: {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isExpanded ? "arrow.up.right.and.arrow.down.left" : "arrow.down.left.and.arrow.up.right")
                                .foregroundColor(Color("ButtonColor"))
                        }
                        .padding(.trailing, 10)
                        Button(action: {
                            editedLocationName = location.name
                            showEditNamePopup = location
                        }) {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(Color("ButtonColor"))
                        }
                        .padding(.trailing, 10)
                        Button(action: {
                            openInMaps(address: location.fullAddress)
                        }) {
                            Image(systemName: "map.fill")
                                .foregroundColor(Color("ButtonColor"))
                        }
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 12)
                    .padding(.horizontal)
                    .background(Color("BackgroundColor"))
                    .onTapGesture {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
                    
                    if isExpanded {
                        VStack(alignment: .leading) {
                            Text(location.streetAddress)
                                .foregroundColor(Color("SecondaryTextColor"))
                            Text("\(location.cityState) \(location.zipCode)")
                                .foregroundColor(Color("SecondaryTextColor"))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                }
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
                .overlay(
                    VStack {
                        Spacer()
                        Divider().background(Color.gray)
                    }
                )
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
