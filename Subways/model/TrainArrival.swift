//
//  TrainArrival.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation
import SwiftData


struct TrainArrival: Identifiable, Comparable, Equatable {
    let tripId: String
    let route: Route
    let direction: Direction
    let time: Date
    let stationName: String
    
    var id: String { tripId }
    
    init(tripId: String, route: Route, direction: Direction, time: Date) {
        self.tripId = tripId
        self.route = route
        self.direction = direction
        self.time = time
        
        let underscoreIdx = tripId.lastIndex(of: "_")!
        self.stationName = Station.get(id: String(tripId[tripId.index(after: underscoreIdx)...])).name
    }
    
    static func < (lhs: TrainArrival, rhs: TrainArrival) -> Bool {
        return lhs.time < rhs.time
    }
    
    static func == (lhs: TrainArrival, rhs: TrainArrival) -> Bool {
        return lhs.tripId == rhs.tripId
    }
}
