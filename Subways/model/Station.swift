//
//  Station.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/5/24.
//

import Foundation

struct Station {
    var id: String
    var name: String
    var arrivals: StationArrivals
    
    static func get(id: String) -> Station {
        return Station(id: id, name: id, arrivals: ArrivalDataProcessor.getArrivals(for: id))
    }
}
