import SwiftUI

struct CategoryLocationsView: View {
    @EnvironmentObject var userState: UserState
    @EnvironmentObject var appState: AppState
    var category: Category
    var onClose: () -> Void
    @State private var editedLocation: Location?
    @State private var showAlert = false
    @State private var selectedLocations = Set<Location>()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(Color("ButtonColor"))
                    .font(.title2)
                Text(category.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("PrimaryTextColor"))
                Spacer()
                Button(action: {
                    showAlert = true
                }) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                        .font(.title)
                }
                .padding(.trailing, 10)
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color("PrimaryTextColor"))
                        .font(.title)
                }
            }
            .padding()
            .background(Color("BackgroundColor"))
                        
            ScrollView {
                if let locations = userState.user?.locations.filter({ $0.category?.id == category.id }), !locations.isEmpty {
                    Divider().background(Color.gray)
                    ForEach(locations) { location in
                        LocationListItem(location: location, showEditNamePopup: $editedLocation, isSelectable: appState.isSelectable, selectedLocations: $selectedLocations)
                            .environmentObject(userState)
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Category"),
                message: Text("Are you sure you want to delete this category? This action will remove the category from all locations and delete the category itself."),
                primaryButton: .destructive(Text("Delete")) {
                    deleteCategory()
                    onClose()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func updateLocation(for location: Location) {
        if let user = userState.user, let index = user.locations.firstIndex(where: { $0.id == location.id }) {
            userState.user?.locations[index] = location
            userState.saveUser(user: userState.user ?? user)
        }
    }

    private func deleteCategory() {
        guard let user = userState.user else { return }
        
        userState.user?.categories.removeAll { $0.id == category.id }

        for index in user.locations.indices {
            if user.locations[index].category?.id == category.id {
                userState.user?.locations[index].category = nil
            }
        }

        userState.saveUser(user: userState.user ?? user)
    }
}
