//
//  ViewModel.swift
//  Subways
//
//  Created by Tejas Narayanan on 12/30/24.
//

import Foundation
import SwiftUI
import ActivityKit

@MainActor
class ViewModel: ObservableObject {
    @Published var downtownArrivals: [TrainArrival] = []
    @Published var uptownArrivals: [TrainArrival] = []
    
    @Published var queryStatus: ArrivalQueryStatus = .SUCCESS
    @Published var lastUpdate: Date? = nil
    private var lastUpdateStationId: String? = nil
    
    @Published var numOngoingFetches: Int = 0
    
    private var liveActivities: [String: Activity<ArrivalStatusAttributes>] = [:]
    
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
            
            await updateLiveActivities()
        } else {
            print("Query resulted in error: \(queryStatus)")
        }
    }
    
    func addLiveActivity(for trainArrival: TrainArrival) {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            do {
                let arrivalAttrs = ArrivalStatusAttributes(tripId: trainArrival.tripId, stationName: trainArrival.stationName, direction: trainArrival.direction, route: trainArrival.route)
                let initialState = ArrivalStatusAttributes.ContentState(arrivalTime: trainArrival.time)
                
                _ = try Activity.request(attributes: arrivalAttrs, content: .init(state: initialState, staleDate: nil), pushType: .none)
                print("Created live activity")
            } catch let error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func removeLiveActivity(for trainArrival: TrainArrival) {
        for activity in Activity<ArrivalStatusAttributes>.activities {
            if activity.attributes.tripId == trainArrival.tripId {
                // cancel live activity
                Task {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
        }
    }
    
    func updateLiveActivities() async {
        for activity in Activity<ArrivalStatusAttributes>.activities {
            let currentActivityArrivalTime = activity.content.state.arrivalTime
            // default to existing time
            var newArrivalTime: Date = currentActivityArrivalTime;
            for lst in [uptownArrivals, downtownArrivals] {
                for arrival in lst {
                    if arrival.tripId == activity.attributes.tripId {
                        newArrivalTime = arrival.time
                    }
                }
            }
            let newContent = ActivityContent<ArrivalStatusAttributes.ContentState>(
                state: ArrivalStatusAttributes.ContentState(arrivalTime: newArrivalTime),
                staleDate: Date().addingTimeInterval(60))
            
            if Date() > newArrivalTime.addingTimeInterval(60) {
                await activity.end(newContent, dismissalPolicy: .immediate)
                print("Ended live activity")
            } else {
                await activity.update(newContent)
                print("Updated live activity")
            }
        }
    }
    
    func getTrainArrivalTripIdsWithLiveActivities() -> Set<String> {
        var tripIds: Set<String> = []
        for activity in Activity<ArrivalStatusAttributes>.activities {
            tripIds.insert(activity.attributes.tripId)
        }
        return tripIds
    }
}
