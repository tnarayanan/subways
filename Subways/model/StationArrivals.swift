//
//  StationArrivals.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation
import HeapModule

struct StationArrivals {
    var arrivals: [Direction: [TrainArrival]] = [Direction.UPTOWN: [], Direction.DOWNTOWN: []]
    
    func getUptownArrivals() -> [TrainArrival] {
        return arrivals[.UPTOWN]!
    }
    
    func getDowntownArrivals() -> [TrainArrival] {
        return arrivals[.DOWNTOWN]!
    }
}
