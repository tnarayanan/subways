//
//  StationArrivals.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation
import HeapModule

struct StationArrivals {
    var arrivals: [Direction: Heap<TrainArrival>] = [Direction.UPTOWN: [], Direction.DOWNTOWN: []]
    
    func getUptownArrivals() -> [TrainArrival] {
        return arrivals[Direction.UPTOWN]!.unordered.sorted()
    }
    
    func getDowntownArrivals() -> [TrainArrival] {
        return arrivals[Direction.DOWNTOWN]!.unordered.sorted()
    }
}
