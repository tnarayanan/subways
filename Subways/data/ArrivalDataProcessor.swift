//
//  ArrivalDataProcessor.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation
import HeapModule
import SwiftData

@ModelActor
actor ArrivalDataProcessor {
    private let dataSources: [String] = ["-ace", "-bdfm", "-g", "-jz", "-nqrw", "-l", "", "-si"]
    private let baseUrlString = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs"
    
    private var messages: [String: TransitRealtime_FeedMessage] = [:]
    
    private var stationArrivalHeaps: [String: [Direction: Heap<TrainArrival>]] = [:]
}

extension ArrivalDataProcessor {
    func queryData() async {
        for dataSource in dataSources {
            let url = URL(string: "\(baseUrlString)\(dataSource)")!
            do {
                let (messageData, _) = try await URLSession.shared.data(from: url)
                let message = try TransitRealtime_FeedMessage.init(contiguousBytes: messageData, extensions: TransitRealtime_Gtfs_u45Realtime_u45Nyct_Extensions)
                messages[dataSource] = message
            } catch let error {
                print(error)
            }
        }
    }
    
    func processArrivals(stationId: String) async {
        stationArrivalHeaps.removeAll(keepingCapacity: true)
        
        let asOfTime: Date = Date()
        
        let clock = ContinuousClock()
        let time = await clock.measure {
            await queryData()
        }
        print("Querying data took \(time)")
        
        let oneMinuteAgo: Date = asOfTime.addingTimeInterval(-60)
        
        var allStations: [Station] = []
        var allArrivals: [TrainArrival] = []
        do {
            allStations = try modelContext.fetch(FetchDescriptor<Station>())
            allArrivals = try modelContext.fetch(FetchDescriptor<TrainArrival>())
        } catch let error {
            print(error)
        }
        
        var stationMap: [String: Station] = [:]
        for station in allStations {
            stationMap[station.stationId] = station
        }
        
        var numTotalArrivals = 0
        
        for msg in messages.values {
            for ent in msg.entity.filter({$0.hasTripUpdate}) {
                let tripUpdate = ent.tripUpdate
                
                let tripID = tripUpdate.trip.tripID
                let route = tripUpdate.trip.hasRouteID ? tripUpdate.trip.routeID : "X"
                
                for stopTimeUpdate in tripUpdate.stopTimeUpdate {
                    let stopIDWithDirection = stopTimeUpdate.hasStopID ? stopTimeUpdate.stopID : "X"
                    let direction = stopIDWithDirection.last! == "N" ? Direction.UPTOWN : Direction.DOWNTOWN
                    let stopID = String(stopIDWithDirection.dropLast())
                    
                    if !stationArrivalHeaps.keys.contains(stopID) {
                        stationArrivalHeaps[stopID] = [.DOWNTOWN: [], .UPTOWN: []]
                    }
                    
                    var timestamp: Int64 = 0
                    if stopTimeUpdate.hasArrival {
                        timestamp = stopTimeUpdate.arrival.time
                    } else if stopTimeUpdate.hasDeparture {
                        timestamp = stopTimeUpdate.departure.time
                    }
                    let trainArrival = TrainArrival(tripId: tripID + "_" + stopID, route: Route(rawValue: route) ?? Route.X, direction: direction, time: Date(timeIntervalSince1970: TimeInterval(timestamp)))
                    
                    numTotalArrivals += 1
                    
                    if trainArrival.time < oneMinuteAgo {
                        continue
                    }
                    
                    stationArrivalHeaps[stopID]![direction]!.insert(trainArrival)
                    if stationArrivalHeaps[stopID]![direction]!.count > 7 {
                        stationArrivalHeaps[stopID]![direction]!.removeMax()
                    }
                }
            }
        }
        
        print("total \(numTotalArrivals)")
            
        var arrivalByTripId: [String: TrainArrival] = [:]
        for arrival in allArrivals {
            if arrival.time < oneMinuteAgo {
                modelContext.delete(arrival)
            } else {
                if let existingArrival = arrivalByTripId[arrival.tripId] {
                    print("DUPLICATE TRIP ID: \(existingArrival.tripId)")
                }
                arrivalByTripId[arrival.tripId] = arrival
            }
        }
        
        for station in allStations {
            if stationArrivalHeaps.keys.contains(station.stationId) {
                for direction in stationArrivalHeaps[station.stationId]!.keys {
                    for newArrival in stationArrivalHeaps[station.stationId]![direction]!.unordered {
                        if let existingArrival = arrivalByTripId[newArrival.tripId] {
                            modelContext.delete(existingArrival)
                        }
                        modelContext.insert(newArrival)
                        newArrival.station = station
                    }
                }
            }
        }
        
        try! modelContext.save()
    }
    
    func queryDataTime() {
        Task {
            let clock = ContinuousClock()
            let time = await clock.measure {
                await queryData()
            }
            print("Querying data took \(time)")
        }
    }
}
