//
//  ViewModel.swift
//  Subways
//
//  Created by Tejas Narayanan on 12/30/24.
//

import Foundation
import HeapModule
import SwiftUI

@MainActor
class ViewModel: ObservableObject {
    @Published var downtownArrivals: [TrainArrival] = []
    @Published var uptownArrivals: [TrainArrival] = []
    
    @Published var queryStatus: ArrivalQueryStatus = .SUCCESS
    @Published var lastUpdate: Date? = nil
    
    @Published var numOngoingFetches = 0
    
    private var stationArrivals: [String: [Direction: Heap<TrainArrival>]] = [:]
    
    let mtaService: MTAService
    
    init() {
        print("******* ViewModel being created ******")
        self.mtaService = MTAService()
    }
    
    func fetchArrivals() async {
        let asOfDate: Date = Date()
        numOngoingFetches += 1
        let fetchResult = await mtaService.fetchArrivals()
        numOngoingFetches -= 1
        if fetchResult.status == .CANCELLED {
            // ignore request
            return
        }
        
        withAnimation {
            queryStatus = fetchResult.status
        }
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
        
        // force an update
        objectWillChange.send()
    }
}
