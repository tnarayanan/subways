//
//  TrainArrival.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation
import SwiftData

@Model
final class TrainArrival: Comparable, Identifiable {
    var tripId: String
    var station: String
    var route: Route
    var time: Date
    
    @Attribute(.unique) var id: String {
        "\(tripId).\(station).\(route.rawValue)"
    }
    
    init(tripId: String, station: String, route: Route, time: Date) {
        self.tripId = tripId
        self.station = station
        self.route = route
        self.time = time
    }
    
    static func < (lhs: TrainArrival, rhs: TrainArrival) -> Bool {
        return lhs.time < rhs.time
    }
}
