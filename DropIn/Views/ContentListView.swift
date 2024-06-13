import SwiftUI

struct ContentListView: View {
    @EnvironmentObject var userState: UserState
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var userLocationManager = UserLocationManager()

    var body: some View {
        ScrollView {
            if let locations = userState.user?.locations, !locations.isEmpty {
                ForEach(groupedLocationsByDate(locations), id: \.key) { date, locations in
                    Section(header: Text(dateFormatter.string(from: date))
                                .foregroundColor(Color("PrimaryTextColor"))
                                .padding(.top)) {
                        ForEach(locations) { location in
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
        .onChange(of: userState.user?.locations) { _, newLocations in
            if let locations = newLocations {
                print("CHANGED: \(locations.count) locations")
            }
        }
        .onChange(of: scenePhase) { _, newValue in
            if case .active = newValue {
                if var locations = userState.user?.locations {
                    for i in locations.indices {
                        locations[i].address = locations[i].address
                    }
                    userState.user?.locations = locations
                }
            }
        }
    }
    
    private func groupedLocationsByDate(_ locations: [Location]) -> [(key: Date, value: [Location])] {
        let groupedDict = Dictionary(grouping: locations) { (location: Location) in
            Calendar.current.startOfDay(for: location.date)
        }
        return groupedDict.sorted { $0.key > $1.key }
    }

    private func openInMaps(address: String) {
        let urlString = "http://maps.apple.com/?q=\(address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
