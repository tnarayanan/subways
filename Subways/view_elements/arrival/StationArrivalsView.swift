//
//  TrainArrivalView.swift
//  Subways
//
//  Created by Tejas Narayanan on 12/29/24.
//

import SwiftUI

struct StationArrivalsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var downtownArrivals: [TrainArrival]
    var uptownArrivals: [TrainArrival]
    var lastUpdate: Date
    @Binding var queryStatus: ArrivalQueryStatus
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            VStack(alignment: .leading) {
                // lastUpdated string and query status
                LastUpdateLabel(curDate: timeline.date, lastUpdate: lastUpdate)
                QueryStatusLabel(queryStatus: $queryStatus)
                
                // train arrival lists
                if horizontalSizeClass == .compact {
                    TrainArrivalList(arrivals: downtownArrivals, direction: .DOWNTOWN, date: timeline.date)
                    TrainArrivalList(arrivals: uptownArrivals, direction: .UPTOWN, date: timeline.date)
                } else {
                    HStack(alignment: .top) {
                        TrainArrivalList(arrivals: downtownArrivals, direction: .DOWNTOWN, date: timeline.date)
                        TrainArrivalList(arrivals: uptownArrivals, direction: .UPTOWN, date: timeline.date)
                    }
                }
            }
        }
    }
}

