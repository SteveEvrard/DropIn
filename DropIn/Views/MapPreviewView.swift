import SwiftUI
import MapKit

struct MapPreviewView: View {
    var location: Location
    var coordinate: CLLocationCoordinate2D
    
    @State private var cameraPosition: MapCameraPosition

    init(location: Location) {
        self.location = location
        self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        _cameraPosition = State(initialValue: MapCameraPosition.region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )))
    }

    var body: some View {
        Map(position: $cameraPosition) {
            Marker(location.name, systemImage: location.category?.icon ?? "mappin", coordinate: coordinate)
        }
            .frame(height: 200)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}
