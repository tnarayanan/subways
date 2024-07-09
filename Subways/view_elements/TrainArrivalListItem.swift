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
            Text("in \(diffs.minute ?? 0) min \(diffs.second ?? 0) sec")
            Spacer()
        }
    }
}

//#Preview {
//    TrainArrivalListItem(trainArrival: TrainArrival(id: "0001", station: "127", route: .FOUR, time: Date()), curTime: Binding<Date>(projectedValue: ))
//}
