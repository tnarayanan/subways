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
    private var lastUpdateStationId: String? = nil
    
    @Published var numOngoingFetches: Int = 0
    
    let mtaService: MTAService
    
    init() {
        print("******* ViewModel being created ******")
        self.mtaService = MTAService()
    }
    
    func fetchArrivals(for station: Station) async {
        if (lastUpdateStationId != station.stationId) {
            // the last station to be updated is not the current one, so
            // we should show the full-screen loading while we load
            lastUpdate = nil
            lastUpdateStationId = station.stationId
            objectWillChange.send()
        }
        
        numOngoingFetches += 1
        let fetchResult = await mtaService.fetchArrivals(for: station)
        numOngoingFetches -= 1
        if fetchResult.status == .CANCELLED {
            // ignore request
            return
        }
        
        withAnimation {
            queryStatus = fetchResult.status
        }
        if queryStatus == .SUCCESS {
            lastUpdate = fetchResult.asOf
            downtownArrivals = fetchResult.arrivals[.DOWNTOWN] ?? []
            uptownArrivals = fetchResult.arrivals[.UPTOWN] ?? []
            print("Query SUCCESS: arrivals backing updated at \(lastUpdate!)")
            print("Updated displayed arrivals for \(station.name)")
            // force an update
            objectWillChange.send()
        } else {
            print("Query resulted in error: \(queryStatus)")
        }
    }
}
