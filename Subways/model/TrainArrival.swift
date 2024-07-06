//
//  TrainArrival.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation

struct TrainArrival: Comparable, Identifiable {
    var id: String
    var station: String
    var route: Route
    var time: Date
    
    static func < (lhs: TrainArrival, rhs: TrainArrival) -> Bool {
        return lhs.time < rhs.time
    }
}
