//
//  ArrivalDataProcessor.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation

class ArrivalDataProcessor {
    private static let dataSources: [String] = ["-ace", "-bdfm", "-g", "-nqrw", "-l", "", "-si"]
    private static let baseUrlString = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs"
    
    private static var messages: [String: TransitRealtime_FeedMessage] = [:]
    
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
    
    public static func processArrivals() async {
        stationArrivals.removeAll(keepingCapacity: true)
        await queryData()
        
        for msg in messages.values {
            for ent in msg.entity.filter({$0.hasTripUpdate}) {
                let tripUpdate = ent.tripUpdate
                
                let tripID = tripUpdate.trip.tripID
                let route = tripUpdate.trip.hasRouteID ? tripUpdate.trip.routeID : "X"
                
                for stopTimeUpdate in tripUpdate.stopTimeUpdate {
                    let stopIDWithDirection = stopTimeUpdate.hasStopID ? stopTimeUpdate.stopID : "X"
                    let direction = stopIDWithDirection.last! == "N" ? Direction.UPTOWN : Direction.DOWNTOWN
                    let stopID = String(stopIDWithDirection.dropLast())
                    
                    if !stationArrivals.keys.contains(stopID) {
                        stationArrivals[stopID] = StationArrivals()
                    }
                    
                    var timestamp: Int64 = 0
                    if stopTimeUpdate.hasArrival {
                        timestamp = stopTimeUpdate.arrival.time
                    } else if stopTimeUpdate.hasDeparture {
                        timestamp = stopTimeUpdate.departure.time
                    }
                    let trainArrival = TrainArrival(id: tripID, station: stopID, route: Route(rawValue: route) ?? Route.X, time: Date(timeIntervalSince1970: TimeInterval(timestamp)))
                    
                    stationArrivals[stopID]!.arrivals[direction]!.insert(trainArrival)
                    if stationArrivals[stopID]!.arrivals[direction]!.count > 7 {
                        stationArrivals[stopID]!.arrivals[direction]!.removeMax()
                    }
                }
            }
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
            print(time)
        }
    }
}
