import SwiftUI
import CoreLocation

struct LocationListItem: View {
    @EnvironmentObject var userState: UserState
    var location: Location
    @Binding var showEditNamePopup: Location?
    var isSelectable: Bool
    @Binding var selectedLocations: Set<Location>
    
    @State private var showAlert = false
    @State private var isExpanded = false
    @State private var showMenu = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    if isSelectable {
                        Button(action: {
                            if selectedLocations.contains(location) {
                                selectedLocations.remove(location)
                            } else {
                                selectedLocations.insert(location)
                            }
                        }) {
                            Image(systemName: selectedLocations.contains(location) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(Color("ButtonColor"))
                                .font(.title2)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text(location.name)
                            .foregroundColor(Color("PrimaryTextColor"))
                        Text(location.cityState)
                            .font(.subheadline)
                            .foregroundColor(Color("SecondaryTextColor"))
                    }
                    Spacer()
                    UpdateLocationButton(location: location)
                        .environmentObject(userState)
                    if let category = location.category {
                        Image(systemName: category.icon)
                            .foregroundColor(Color("ButtonColor"))
                            .font(.title2)
                    }
                    Button(action: {
                        showEditNamePopup = location
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(Color("ButtonColor"))
                            .font(.title2)
                    }
                    Button(action: {
                        showMenu.toggle()
                    }) {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(Color("ButtonColor"))
                            .font(.title2)
                    }
                    .actionSheet(isPresented: $showMenu) {
                        ActionSheet(title: Text("Options"), buttons: [
                            .default(Text("Expand")) {
                                withAnimation {
                                    isExpanded.toggle()
                                }
                            },
                            .default(Text("Open in Apple Maps")) {
                                openInAppleMaps(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                            },
                            .default(Text("Open in Google Maps")) {
                                openInGoogleMaps(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                            },
                            .default(Text("Copy Address")) {
                                copyToClipboard(text: location.fullAddress)
                            },
                            .destructive(Text("Delete")) {
                                showAlert = true
                            },
                            .cancel()
                        ])
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, 12)
                .padding(.horizontal)
                .background(Color("BackgroundColor"))
                .onTapGesture {
                    if !isExpanded {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } else {
                        isExpanded.toggle()
                    }
                }
                
                if isExpanded {
                    ExpandedLocationView(location: location)
                }
            }
            .background(Color("BackgroundColor"))
            .overlay(
                VStack {
                    Spacer()
                    Divider().background(Color.gray)
                }
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Location"),
                message: Text("Are you sure you want to delete this location?"),
                primaryButton: .destructive(Text("Delete")) {
                    withAnimation {
                        userState.removeLocation(locationId: location.id)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}
