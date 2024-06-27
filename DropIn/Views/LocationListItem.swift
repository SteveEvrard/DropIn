import SwiftUI
import CoreLocation

struct LocationListItem: View {
    @EnvironmentObject var userState: UserState
    var location: Location
    @Binding var showEditNamePopup: Location?
    
    @State private var showAlert = false
    @State private var isExpanded = false
    @State private var showMenu = false
    
    var body: some View {
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
                    if let category = location.category {
                        Image(systemName: category.icon)
                            .foregroundColor(Color("ButtonColor"))
                            .padding(.trailing, 10)
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
                            .default(Text("Edit")) {
                                showEditNamePopup = location
                            },
                            .default(Text("Open in Apple Maps")) {
                                openInAppleMaps(address: location.fullAddress)
                            },
                            .default(Text("Open in Google Maps")) {
                                openInGoogleMaps(address: location.fullAddress)
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
                    VStack(alignment: .leading) {
                        HStack {
                            Text(location.streetAddress)
                                .foregroundColor(Color("SecondaryTextColor"))
                            Spacer()
                            if let category = location.category {
                                HStack(spacing: 5) {
                                    Image(systemName: category.icon)
                                        .foregroundColor(Color("ButtonColor"))
                                    Text(category.name)
                                        .foregroundColor(Color("PrimaryTextColor"))
                                }
                            }
                        }
                        HStack {
                            Text("\(location.cityState) \(location.zipCode)")
                                .foregroundColor(Color("SecondaryTextColor"))
                            Spacer()
                        }
                        MapPreviewView(location: location)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
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
