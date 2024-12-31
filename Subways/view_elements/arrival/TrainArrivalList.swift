//
//  TrainArrivalList.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/8/24.
//

import SwiftUI
import SwiftData

struct TrainArrivalList: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    
    var arrivals: [TrainArrival]
    var direction: Direction
    var date: Date
    
    var body: some View {
        let groupBoxColor = colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white
        
        VStack(alignment: .leading) {
            Text(direction.rawValue.capitalized(with: nil)).font(.title3).bold()
                .padding(.top)
            
            GroupBox {
                if arrivals.count == 0 {
                    HStack {
                        Text("No arrivals found")
                        Spacer()
                    }
                } else {
                    ForEach(Array(arrivals.sorted().enumerated()), id: \.offset) { index, arrival in
                        TrainArrivalListItem(trainArrival: arrival, curTime: date)
                            .padding(.top, index == 0 ? 0 : 4)
                            .padding(.bottom, index == arrivals.count - 1 ? 0 : 4)
                        if index != arrivals.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .backgroundStyle(groupBoxColor)
    }
}

#Preview {
    @Previewable @Environment(\.colorScheme) var colorScheme
    
    VStack {
        Spacer()
        TrainArrivalList(
            arrivals: [
                TrainArrival(tripId: "t1", route: .SEVEN, direction: .DOWNTOWN, time: Date().addingTimeInterval(10)),
                TrainArrival(tripId: "t2", route: .N, direction: .DOWNTOWN, time: Date().addingTimeInterval(95)),
                TrainArrival(tripId: "t3", route: .SIX_EXPRESS, direction: .DOWNTOWN, time: Date().addingTimeInterval(-32))
            ],
            direction: .DOWNTOWN,
            date: Date()
        )
        .padding(.horizontal)
        TrainArrivalList(
            arrivals: [],
            direction: .UPTOWN,
            date: Date()
        )
        .padding(.horizontal)
        Spacer()
    }
    .background(Color(colorScheme == .light ? UIColor.systemGray6 : UIColor.black))
}
