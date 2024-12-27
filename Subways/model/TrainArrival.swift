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
    @Attribute(.unique) var tripId: String
    var stationId: String
    var route: Route
    var direction: Direction
    var time: Date
    
    
    init(tripId: String, stationId: String, route: Route, direction: Direction, time: Date) {
        self.tripId = tripId
        self.stationId = stationId
        self.route = route
        self.direction = direction
        self.time = time
    }
    
    static func < (lhs: TrainArrival, rhs: TrainArrival) -> Bool {
        return lhs.time < rhs.time
    }
}
