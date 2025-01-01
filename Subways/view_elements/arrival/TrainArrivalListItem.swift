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
    var showDivider: Bool
    
    var body: some View {
        let diffs = Calendar.current.dateComponents([.minute, .second], from: curTime, to: trainArrival.time)
        VStack {
            HStack {
                RouteSymbol(route: trainArrival.route, size: .arrival)
                
                VStack(alignment: .leading) {
                    let minutes = diffs.minute ?? 0
                    let seconds = diffs.second ?? 0
                    let timeStr = "\(abs(minutes)) min \(abs(seconds)) sec"
                    
                    if (minutes >= 0 && seconds >= 0) {
                        Text("in \(timeStr)")
                            .monospacedDigit()
                    } else {
                        Text("\(timeStr) ago")
                            .monospacedDigit()
                            .foregroundStyle(Color.red)
                    }
                    
                    let arrivalTimeStr = trainArrival.time.formatted(date: .omitted, time: .shortened)
                    Text("\(arrivalTimeStr)")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: {}, label: {
                    Label("Add to live activity", systemImage: "clock.badge").labelStyle(.iconOnly)
                }).foregroundStyle(.secondary).hidden()
            }
            if showDivider {
                Divider()
            }
        }
    }
}

#Preview {
    TrainArrivalListItem(trainArrival: TrainArrival(tripId: "0001", route: .FOUR, direction: .DOWNTOWN, time: Date()), curTime: Date().addingTimeInterval(-168), showDivider: false)
        .padding()
    TrainArrivalListItem(trainArrival: TrainArrival(tripId: "0001", route: .FOUR, direction: .DOWNTOWN, time: Date()), curTime: Date().addingTimeInterval(62), showDivider: false)
        .padding()
}
