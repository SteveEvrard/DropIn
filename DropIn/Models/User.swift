//
//  User.swift
//  DropIn
//
//  Created by Stephen Evrard on 6/12/24.
//

struct User: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var email: String
    var locations: [Location]

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.email == rhs.email &&
               lhs.locations == rhs.locations
    }
}
