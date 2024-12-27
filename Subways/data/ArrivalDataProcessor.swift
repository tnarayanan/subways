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
            let url = URL(string: "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs\(dataSource)")!
            do {
                let (messageData, _) = try await URLSession.shared.data(from: url)
                let message = try TransitRealtime_FeedMessage.init(contiguousBytes: messageData, extensions: TransitRealtime_Gtfs_u45Realtime_u45Nyct_Extensions)
                messages[dataSource] = message
            } catch let error {
                print(error)
            }
        }
    }
    
    func processArrivals() async {
        stationArrivalHeaps.removeAll(keepingCapacity: true)
        
        let clock = ContinuousClock()
        let time = await clock.measure {
            await queryData()
        }
        print("Querying data took \(time)")
        
        let oneMinuteAgo: Date = Date().addingTimeInterval(-60)
        
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
                    let trainArrival = TrainArrival(tripId: tripID, route: Route(rawValue: route) ?? Route.X, direction: direction, time: Date(timeIntervalSince1970: TimeInterval(timestamp)))
                    
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
        
        try! modelContext.transaction {
            print("Beginning transaction")
            var allStations: [Station] = []
            var allArrivals: [TrainArrival] = []
            do {
                allStations = try modelContext.fetch(FetchDescriptor<Station>())
                allArrivals = try modelContext.fetch(FetchDescriptor<TrainArrival>())
            } catch let error {
                print(error)
            }
            
            var arrivalByUniqueId: [String: TrainArrival] = [:]
            for arrival in allArrivals {
                if arrival.time < oneMinuteAgo {
                    modelContext.delete(arrival)
                } else {
                    arrivalByUniqueId[arrival.uniqueId] = arrival
                }
            }
            
            for station in allStations {
                if stationArrivalHeaps.keys.contains(station.stationId) {
                    for direction in stationArrivalHeaps[station.stationId]!.keys {
                        if station.stationId == "631" { print("\(station.stationId) -> \(direction): \(stationArrivalHeaps[station.stationId]![direction]!.count)") }
                        for newArrival in stationArrivalHeaps[station.stationId]![direction]!.unordered {
                            if station.stationId == "631" { print("\t\(newArrival.uniqueId)") }
                            if let existingArrival = arrivalByUniqueId[newArrival.uniqueId] {
                                if station.stationId == "631" { print("\t\tExisting arrival") }
                                existingArrival.time = newArrival.time
                            } else {
                                if station.stationId == "631" { print("\t\tNew arrival") }
                                let arrivalToAdd = TrainArrival(tripId: newArrival.tripId, station: station, route: newArrival.route, direction: newArrival.direction, time: newArrival.time)
                                station.arrivals.append(arrivalToAdd)
                            }
                        }
                    }
                }
            }
            
            print("Finishing transaction")
            try! modelContext.save()
        }
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
