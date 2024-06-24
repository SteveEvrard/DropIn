import SwiftUI

struct CategoryLocationsView: View {
    @EnvironmentObject var userState: UserState
    var category: Category
    var onClose: () -> Void
    @State private var editedLocation: Location?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(Color("PrimaryTextColor"))
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                }
            }
            .padding()
            .background(Color("BackgroundColor"))
            
            Divider().background(Color.gray)
            
            ScrollView {
                if let locations = userState.user?.locations.filter({ $0.category?.id == category.id }), !locations.isEmpty {
                    ForEach(locations) { location in
                        LocationListItem(location: location, showEditNamePopup: $editedLocation)
                            .environmentObject(userState)
                            .padding(.horizontal)
                    }
                } else {
                    Text("No locations in this category")
                        .foregroundColor(Color("SecondaryTextColor"))
                        .padding()
                }
            }
        }
        .overlay(
            Group {
                if let location = editedLocation {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            self.editedLocation = nil
                        }
                    EditLocationView(
                        location: Binding(
                            get: { location },
                            set: { self.editedLocation = $0 }
                        ),
                        onSave: {
                            updateLocation(for: location)
                            self.editedLocation = nil
                        },
                        onCancel: {
                            self.editedLocation = nil
                        }
                    )
                    .environmentObject(userState)
                }
            }
        )
        .background(Color("BackgroundColor"))
        .cornerRadius(12)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func updateLocation(for location: Location) {
        if let user = userState.user, let index = user.locations.firstIndex(where: { $0.id == location.id }) {
            userState.user?.locations[index] = location
            userState.saveUser(user: userState.user ?? user)
        }
    }
}
