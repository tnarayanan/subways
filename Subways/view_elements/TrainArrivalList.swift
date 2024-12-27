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
    
//    var arrivals: StationArrivals
    @Bindable var station: Station
    var direction: Direction
    var date: Date
    
    private var stationArrivals: [TrainArrival] {
        let fetchDescriptor = FetchDescriptor<TrainArrival>()
        return (try? modelContext.fetch(fetchDescriptor)) ?? []
    }
    
    var body: some View {
        let groupBoxColor = colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white
        
        GroupBox {
            let arrivalsList: [TrainArrival] = stationArrivals.filter { $0.stationId == station.stationId && $0.direction == direction }

            ForEach(Array(arrivalsList.sorted().enumerated()), id: \.offset) { index, arrival in
                TrainArrivalListItem(trainArrival: arrival, curTime: date)
                    .padding(.vertical, 4)
                if index != arrivalsList.count - 1 {
                    Divider()
                }
            }
        }
        .backgroundStyle(groupBoxColor)
    }
}

//#Preview {
//    TrainArrivalList()
//}
