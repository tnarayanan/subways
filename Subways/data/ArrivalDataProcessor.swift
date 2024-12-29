//
//  ArrivalDataProcessor.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation
import HeapModule
import SwiftData

enum DataSource: String, CaseIterable, Codable {
    case ACE = "-ace"
    case BDFM = "-bdfm"
    case G = "-g"
    case JZ = "-jz"
    case NQRW = "-nqrw"
    case L = "-l"
    case NUMS = ""
    case SI = "-si"
}

enum ArrivalQueryStatus {
    case SUCCESS, FAILURE, NO_INTERNET
}

//@ModelActor
actor ArrivalDataProcessor {
    private let baseUrlString = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs"
    
    private var messages: [DataSource: TransitRealtime_FeedMessage] = [:]
    
    private var stationArrivalHeaps: [String: [Direction: Heap<TrainArrivalDTO>]] = [:]

    func queryData() async -> ArrivalQueryStatus {
        for dataSource in DataSource.allCases {
            let url = URL(string: "\(baseUrlString)\(dataSource.rawValue)")!
            do {
                let (messageData, _) = try await URLSession.shared.data(from: url)
                let message = try TransitRealtime_FeedMessage.init(contiguousBytes: messageData, extensions: TransitRealtime_Gtfs_u45Realtime_u45Nyct_Extensions)
                messages[dataSource] = message
            } catch let error {
                if let urlError = error as? URLError {
                    if urlError.code == .notConnectedToInternet {
                        return .NO_INTERNET
                    }
                }
                return .FAILURE
            }
        }
        return .SUCCESS
    }
    
    func getArrivals(for stationId: String) async -> [Direction: Heap<TrainArrivalDTO>] {
        return stationArrivalHeaps[stationId] ?? [.DOWNTOWN: [], .UPTOWN: []]
    }
    
    func processArrivals() async -> ArrivalQueryStatus {
        var tmpStationArrivalHeaps: [String: [Direction: Heap<TrainArrivalDTO>]] = [:]
        
        let asOfTime: Date = Date()
        
        let clock = ContinuousClock()
        var queryStatus: ArrivalQueryStatus = .FAILURE
        let time = await clock.measure {
            queryStatus = await queryData()
        }
        print("Querying data took \(time)")
        if queryStatus != .SUCCESS {
            return queryStatus
        }
        
        let oneMinuteAgo: Date = asOfTime.addingTimeInterval(-60)
        
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
                    
                    if !tmpStationArrivalHeaps.keys.contains(stopID) {
                        tmpStationArrivalHeaps[stopID] = [.DOWNTOWN: [], .UPTOWN: []]
                    }
                    
                    var timestamp: Int64 = 0
                    if stopTimeUpdate.hasArrival {
                        timestamp = stopTimeUpdate.arrival.time
                    } else if stopTimeUpdate.hasDeparture {
                        timestamp = stopTimeUpdate.departure.time
                    }
                    let trainArrival = TrainArrivalDTO(tripId: tripID + "_" + stopID, route: Route(rawValue: route) ?? Route.X, direction: direction, time: Date(timeIntervalSince1970: TimeInterval(timestamp)))
                    
                    numTotalArrivals += 1
                    
                    if trainArrival.time < oneMinuteAgo {
                        continue
                    }
                    
                    tmpStationArrivalHeaps[stopID]![direction]!.insert(trainArrival)
                    if tmpStationArrivalHeaps[stopID]![direction]!.count > 7 {
                        tmpStationArrivalHeaps[stopID]![direction]!.removeMax()
                    }
                }
            }
        }
        
        print("total \(numTotalArrivals)")
        
        stationArrivalHeaps = tmpStationArrivalHeaps
        
        return .SUCCESS
    }
}
