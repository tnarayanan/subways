//
//  TrainArrivalListItem.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import SwiftUI

struct TrainArrivalListItem: View {
    var trainArrival: TrainArrival
    var curTime: Date
    
    var body: some View {
        let diffs = Calendar.current.dateComponents([.minute, .second], from: curTime, to: trainArrival.time)
        HStack {
            RouteSymbol(route: trainArrival.route, size: .regular)
            
            let minutes = diffs.minute ?? 0
            let seconds = diffs.second ?? 0
            if (minutes >= 0 && seconds >= 0) {
                Text("in \(minutes) min \(seconds) sec")
            } else {
                Text("\(-minutes) min \(-seconds) sec ago")
                    .foregroundStyle(Color.red)
            }
            Spacer()
        }
    }
}

#Preview {
    TrainArrivalListItem(trainArrival: TrainArrival(tripId: "0001", route: .FOUR, direction: .DOWNTOWN, time: Date()), curTime: Date().addingTimeInterval(-168))
        .padding()
    TrainArrivalListItem(trainArrival: TrainArrival(tripId: "0001", route: .FOUR, direction: .DOWNTOWN, time: Date()), curTime: Date().addingTimeInterval(62))
        .padding()
}
