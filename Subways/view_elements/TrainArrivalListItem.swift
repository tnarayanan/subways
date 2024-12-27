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
            RouteSymbol(route: trainArrival.route, size: 16)
            if (diffs.second ?? 0) >= 0 {
                Text("in \(diffs.minute ?? 0) min \(diffs.second ?? 0) sec")
            } else {
                Text("\(-(diffs.minute ?? 0)) min \(-(diffs.second ?? 0)) sec ago")
                    .foregroundStyle(Color.red)
            }
            Spacer()
        }
    }
}

#Preview {
    TrainArrivalListItem(trainArrival: TrainArrival(tripId: "0001", route: .FOUR, direction: .DOWNTOWN, time: Date()), curTime: Date())
}
