import Foundation

struct Category: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var icon: String

    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.icon == rhs.icon
    }
}
