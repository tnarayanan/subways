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
    /*@Attribute(.unique)*/ var tripId: String
    var station: Station?
    var route: Route
    var direction: Direction
    var time: Date
    
    
    init(tripId: String, route: Route, direction: Direction, time: Date) {
        self.tripId = tripId
        self.route = route
        self.direction = direction
        self.time = time
    }
    
    static func < (lhs: TrainArrival, rhs: TrainArrival) -> Bool {
        return lhs.time < rhs.time
    }
}

final class TrainArrivalDTO: Sendable, Identifiable, Comparable {
    
    let tripId: String
    let route: Route
    let direction: Direction
    let time: Date
    
    init(tripId: String, route: Route, direction: Direction, time: Date) {
        self.tripId = tripId
        self.route = route
        self.direction = direction
        self.time = time
    }
    
    static func < (lhs: TrainArrivalDTO, rhs: TrainArrivalDTO) -> Bool {
        return lhs.time < rhs.time
    }
    
    static func == (lhs: TrainArrivalDTO, rhs: TrainArrivalDTO) -> Bool {
        return lhs.tripId == rhs.tripId
    }
}
