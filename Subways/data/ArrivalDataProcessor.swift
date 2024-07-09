//
//  ArrivalDataProcessor.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation
import HeapModule
import SwiftData

class ArrivalDataProcessor {
    private static let dataSources: [String] = ["-ace", "-bdfm", "-g", "-jz", "-nqrw", "-l", "", "-si"]
    private static let baseUrlString = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs"
    
    private static var messages: [String: TransitRealtime_FeedMessage] = [:]
    
    private static var stationArrivalHeaps: [String: [Direction: Heap<TrainArrival>]] = [:]
    private static var stationArrivals: [String: StationArrivals] = [:]
    
    private static func queryData() async {
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
    
    @MainActor
    public static func processArrivals(modelContext: ModelContext) async {
        stationArrivalHeaps.removeAll(keepingCapacity: true)
        stationArrivals.removeAll(keepingCapacity: true)
        
        var allStations: [Station] = []
        do {
            try modelContext.delete(model: TrainArrival.self)
            allStations = try modelContext.fetch(FetchDescriptor<Station>())
        } catch let error {
            print(error)
        }
        
        let clock = ContinuousClock()
        let time = await clock.measure {
            await queryData()
        }
        print("Querying data took \(time)")
        
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
                    let trainArrival = TrainArrival(tripId: tripID, stationId: stopID, route: Route(rawValue: route) ?? Route.X, time: Date(timeIntervalSince1970: TimeInterval(timestamp)))
                    
                    stationArrivalHeaps[stopID]![direction]!.insert(trainArrival)
                    if stationArrivalHeaps[stopID]![direction]!.count > 7 {
                        stationArrivalHeaps[stopID]![direction]!.removeMax()
                    }
                }
            }
        }
        
        for station in allStations {
            if stationArrivalHeaps.keys.contains(station.id) {
                station.downtownArrivals = stationArrivalHeaps[station.id]![.DOWNTOWN]!.unordered.sorted()
                station.uptownArrivals = stationArrivalHeaps[station.id]![.UPTOWN]!.unordered.sorted()
            }
        }
        
        for stopID in stationArrivalHeaps.keys {
            stationArrivals[stopID] = StationArrivals()
            stationArrivals[stopID]!.arrivals[.DOWNTOWN] = stationArrivalHeaps[stopID]![.DOWNTOWN]!.unordered.sorted()
            stationArrivals[stopID]!.arrivals[.UPTOWN] = stationArrivalHeaps[stopID]![.UPTOWN]!.unordered.sorted()
        }
    }
    
    public static func getArrivals(for station: String) -> StationArrivals {
        return stationArrivals[station] ?? StationArrivals()
    }
    
    public static func queryDataTime() {
        Task {
            let clock = ContinuousClock()
            let time = await clock.measure {
                await queryData()
            }
            print("Querying data took \(time)")
        }
    }
}
