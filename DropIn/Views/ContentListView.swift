import SwiftUI

struct ContentListView: View {
    @EnvironmentObject var userState: UserState
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var userLocationManager = UserLocationManager()
    @State private var editedLocation: Location?

    var body: some View {
        ScrollView {
            if let locations = userState.user?.locations, !locations.isEmpty {
                ForEach(groupedLocationsByDate(locations), id: \.key) { date, locations in
                    Section(header: Text(dateFormatter.string(from: date))
                                .foregroundColor(Color("PrimaryTextColor"))
                                .padding(.top)) {
                        Divider().background(Color.gray)
                        ForEach(locations) { location in
                            LocationListItem(location: location, showEditNamePopup: $editedLocation)
                                .environmentObject(userState)
                        }
                    }
                }
            } else {
                Text("No locations saved")
                    .padding()
                    .foregroundColor(Color("SecondaryTextColor"))
            }

            if !userLocationManager.locationAccessGranted {
                Button(action: {
                    userLocationManager.requestLocationAccess()
                }) {
                    Text("Allow Location Access")
                        .foregroundColor(Color("ButtonTextColor"))
                        .padding()
                        .background(Color("ButtonColor"))
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .padding(.top, -8)
        .onChange(of: scenePhase) { _, newValue in
            if case .active = newValue {
                if var locations = userState.user?.locations {
                    for i in locations.indices {
                        locations[i].fullAddress = locations[i].fullAddress
                    }
                    userState.user?.locations = locations
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
    }

    private func groupedLocationsByDate(_ locations: [Location]) -> [(key: Date, value: [Location])] {
        let groupedDict = Dictionary(grouping: locations) { (location: Location) in
            Calendar.current.startOfDay(for: location.date)
        }
        return groupedDict.sorted { $0.key > $1.key }
    }

    private func updateLocation(for location: Location) {
        if let user = userState.user, let index = user.locations.firstIndex(where: { $0.id == location.id }) {
            userState.user?.locations[index] = location
            userState.saveUser(user: userState.user ?? user)
        }
    }
}
