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
    var isFetching: Bool
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            VStack(alignment: .leading) {
                // last update string and query status
                HStack {
                    LastUpdateLabel(curDate: timeline.date, lastUpdate: lastUpdate)
                    if isFetching {
                        ProgressView()
                    } else {
                        ProgressView().hidden()
                    }
                }
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

#Preview {
    struct Preview: View {
        @Environment(\.colorScheme) var colorScheme
        @State var queryStatus: ArrivalQueryStatus = .SUCCESS
        var body: some View {
            VStack {
                Spacer()
                StationArrivalsView(
                    downtownArrivals: [
                        TrainArrival(tripId: "t1", route: .SEVEN, direction: .DOWNTOWN, time: Date().addingTimeInterval(10)),
                        TrainArrival(tripId: "t2", route: .N, direction: .DOWNTOWN, time: Date().addingTimeInterval(95)),
                        TrainArrival(tripId: "t3", route: .SIX_EXPRESS, direction: .DOWNTOWN, time: Date().addingTimeInterval(-32))
                    ],
                    uptownArrivals: [],
                    lastUpdate: Date(),
                    queryStatus: $queryStatus,
                    isFetching: true
                )
                .padding(.horizontal)
                Spacer()
            }
            .background(Color(colorScheme == .light ? UIColor.systemGray6 : UIColor.black))
        }
    }
    
    return Preview()
}
