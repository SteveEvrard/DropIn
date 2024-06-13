//
//  LocationManagerHelper.swift
//  DropIn
//
//  Created by Stephen Evrard on 5/24/24.
//

import Foundation

struct Location: Codable, Identifiable, Equatable {
    var id = UUID()
    let latitude: Double
    let longitude: Double
    let date: Date
    var name: String
    var address: String?
    var cityState: String?

    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id &&
               lhs.latitude == rhs.latitude &&
               lhs.longitude == rhs.longitude &&
               lhs.date == rhs.date &&
               lhs.name == rhs.name &&
               lhs.address == rhs.address &&
               lhs.cityState == rhs.cityState
    }
}
