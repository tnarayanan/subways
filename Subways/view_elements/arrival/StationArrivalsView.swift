//
//  TrainArrivalView.swift
//  Subways
//
//  Created by Tejas Narayanan on 12/29/24.
//

import SwiftUI

struct StationArrivalsView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var station: Station
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
                    TrainArrivalList(station: station, direction: .DOWNTOWN, date: timeline.date)
                    TrainArrivalList(station: station, direction: .UPTOWN, date: timeline.date)
                } else {
                    HStack(alignment: .top) {
                        TrainArrivalList(station: station, direction: .DOWNTOWN, date: timeline.date)
                        TrainArrivalList(station: station, direction: .UPTOWN, date: timeline.date)
                    }
                }
            }
        }
    }
}

