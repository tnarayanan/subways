//
//  ArrivalDataProcessor.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation
import HeapModule
import SwiftData

enum ArrivalQueryStatus {
    case SUCCESS, FAILURE, CANCELLED, NO_INTERNET
}

struct Response: Codable {
    let D: [TrainArrivalResponse]
    let U: [TrainArrivalResponse]
    let asOf: Int
}

struct TrainArrivalResponse: Codable {
    let id: String
    let rt: String
    let dir: String
    let time: Int
}

//@ModelActor
actor MTAService {
    private let baseUrlString = "https://subways-api.tejasnarayanan.com/arrivals/"

    private func queryData(for station: Station) async -> (status: ArrivalQueryStatus, response: Response?) {
        if let url = URL(string: "\(baseUrlString)\(station.stationId)") {
            do {
                let (responseData, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(Response.self, from: responseData)
                return (.SUCCESS, response)
            } catch let error {
                if let urlError = error as? URLError {
                    if urlError.code == .notConnectedToInternet {
                        return (.NO_INTERNET, nil)
                    } else if urlError.code == .cancelled {
                        return (.CANCELLED, nil)
                    }
                }
                print(error)
                return (.FAILURE, nil)
            }
        }
        return (.FAILURE, nil)
    }
    
    func fetchArrivals(for station: Station) async -> (status: ArrivalQueryStatus, arrivals: [Direction: [TrainArrival]], asOf: Date?) {
        let clock = ContinuousClock()
        
        var queryResult: (status: ArrivalQueryStatus, response: Response?) = (status: .FAILURE, response: nil)
        
        let time = await clock.measure {
            queryResult = await queryData(for: station)
        }
        print("Querying data took \(time)")
        if queryResult.status != .SUCCESS || queryResult.response == nil {
            return (queryResult.status, [:], nil)
        }
        
        let arrivals: [Direction: [TrainArrival]] = [
            .DOWNTOWN: queryResult.response!.D.map(trainArrivalResponseToTrainArrival),
            .UPTOWN: queryResult.response!.U.map(trainArrivalResponseToTrainArrival)
        ]
        
        return (.SUCCESS, arrivals, Date(timeIntervalSince1970: TimeInterval(queryResult.response!.asOf)))
    }
    
    private func trainArrivalResponseToTrainArrival(_ resp: TrainArrivalResponse) -> TrainArrival {
        return TrainArrival(
            tripId: resp.id,
            route: Route(rawValue: resp.rt) ?? Route.X,
            direction: resp.dir == "D" ? .DOWNTOWN : .UPTOWN,
            time: Date(timeIntervalSince1970: TimeInterval(resp.time))
        )
    }
}
