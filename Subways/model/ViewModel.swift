//
//  ViewModel.swift
//  Subways
//
//  Created by Tejas Narayanan on 12/30/24.
//

import Foundation
import HeapModule

@MainActor
class ViewModel: ObservableObject {
    @Published var downtownArrivals: [TrainArrival] = []
    @Published var uptownArrivals: [TrainArrival] = []
    
    @Published var queryStatus: ArrivalQueryStatus = .SUCCESS
    @Published var lastUpdate: Date? = nil
    
    private var stationArrivals: [String: [Direction: Heap<TrainArrival>]] = [:]
    
    let mtaService: MTAService
    
    init() {
        self.mtaService = MTAService()
    }
    
    func fetchArrivals() async {
        let asOfDate: Date = Date()
        let fetchResult = await mtaService.fetchArrivals()
        queryStatus = fetchResult.status
        
        if queryStatus == .SUCCESS {
            lastUpdate = asOfDate
            stationArrivals = fetchResult.arrivals
            print("Query SUCCESS: arrivals backing updated at \(lastUpdate!)")
        } else {
            print("Query resulted in error: \(queryStatus)")
        }
    }
    
    func updateArrivals(for station: Station) {
        downtownArrivals = Array((stationArrivals[station.stationId]?[.DOWNTOWN]?.unordered ?? []))
        uptownArrivals = Array((stationArrivals[station.stationId]?[.UPTOWN]?.unordered ?? []))
        print("Updated displayed arrivals for \(station.name)")
    }
}
