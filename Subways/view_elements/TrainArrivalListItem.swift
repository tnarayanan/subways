//
//  TrainArrivalListItem.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import SwiftUI

struct TrainArrivalListItem: View {
    @State var trainArrival: TrainArrival
    @Binding var curTime: Date
    
    var body: some View {
        let diffs = Calendar.current.dateComponents([.minute, .second], from: curTime, to: trainArrival.time)
        return HStack {
            RouteSymbol(route: trainArrival.route, size: 18)
            Text("in \(diffs.minute ?? 0) min \(diffs.second ?? 0) sec")
        }
    }
}

//#Preview {
//    TrainArrivalListItem(trainArrival: TrainArrival(id: "0001", station: "127", route: .FOUR, time: Date()), curTime: Binding<Date>(projectedValue: ))
//}
