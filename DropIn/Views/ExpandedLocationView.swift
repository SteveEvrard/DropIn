import SwiftUI
import CoreLocation

struct ExpandedLocationView: View {
    var location: Location
    
    var body: some View {
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
            if let description = location.description, !description.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Notes:")
                        .font(.headline)
                        .foregroundColor(Color("PrimaryTextColor"))
                    Text(description)
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                .padding(.top, 5)
            }
            MapPreviewView(location: location)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}
