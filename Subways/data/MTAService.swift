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
    case SUCCESS, FAILURE, CANCELLED, NO_INTERNET
}

//@ModelActor
actor MTAService {
    private let baseUrlString = "https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs"

    private func queryData() async -> (status: ArrivalQueryStatus, messages: [DataSource: TransitRealtime_FeedMessage]) {
        var messages: [DataSource: TransitRealtime_FeedMessage] = [:]
        
        for dataSource in DataSource.allCases {
            let url = URL(string: "\(baseUrlString)\(dataSource.rawValue)")!
            do {
                let (messageData, _) = try await URLSession.shared.data(from: url)
                let message = try TransitRealtime_FeedMessage.init(contiguousBytes: messageData, extensions: TransitRealtime_Gtfs_u45Realtime_u45Nyct_Extensions)
                messages[dataSource] = message
            } catch let error {
                if let urlError = error as? URLError {
                    if urlError.code == .notConnectedToInternet {
                        return (.NO_INTERNET, [:])
                    } else if urlError.code == .cancelled {
                        return (.CANCELLED, [:])
                    }
                }
                print(error)
                return (.FAILURE, [:])
            }
        }
        return (.SUCCESS, messages)
    }
    
    func fetchArrivals() async -> (status: ArrivalQueryStatus, arrivals: [String: [Direction: Heap<TrainArrival>]]) {
        var stationArrivalHeaps: [String: [Direction: Heap<TrainArrival>]] = [:]
        
        let asOfTime: Date = Date()
        
        let clock = ContinuousClock()
        
        var queryResult: (status: ArrivalQueryStatus, messages: [DataSource: TransitRealtime_FeedMessage]) = (status: .FAILURE, messages: [:])
        
        let time = await clock.measure {
            queryResult = await queryData()
        }
        print("Querying data took \(time)")
        if queryResult.status != .SUCCESS {
            return (queryResult.status, [:])
        }
        
        let oneMinuteAgo: Date = asOfTime.addingTimeInterval(-60)
        
        var numTotalArrivals = 0
        
        for msg in queryResult.messages.values {
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
        
        return (.SUCCESS, stationArrivalHeaps)
    }
}
