import Foundation

struct Location: Codable, Identifiable, Equatable {
    var id = UUID()
    let latitude: Double
    let longitude: Double
    let date: Date
    var name: String
    var fullAddress: String
    var streetAddress: String
    var cityState: String
    var zipCode: String
    var category: Category?
    var description: String?

    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id &&
               lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude &&
               lhs.date == rhs.date &&
               lhs.name == rhs.name &&
               lhs.fullAddress == rhs.fullAddress &&
               lhs.streetAddress == rhs.streetAddress &&
               lhs.cityState == rhs.cityState &&
               lhs.zipCode == rhs.zipCode &&
               lhs.category?.id == rhs.category?.id &&
               lhs.description == rhs.description
    }
}
