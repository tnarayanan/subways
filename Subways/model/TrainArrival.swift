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
    var station: Station?
    var route: Route
    var direction: Direction
    var time: Date
    
    var uniqueId: String {
        "\(tripId).\(direction.rawValue).\(route.rawValue)"
    }
    
    init(tripId: String, station: Station? = nil, route: Route, direction: Direction, time: Date) {
        self.tripId = tripId
        self.station = station
        self.route = route
        self.direction = direction
        self.time = time
    }
    
    static func < (lhs: TrainArrival, rhs: TrainArrival) -> Bool {
        return lhs.time < rhs.time
    }
}
