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
    
    @Bindable var station: Station
    var direction: Direction
    var date: Date
    
    var body: some View {
        let groupBoxColor = colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white
        
        GroupBox {
            let arrivalsList: [TrainArrival] = station.arrivals!.filter { $0.direction == direction }

            ForEach(Array(arrivalsList.sorted().enumerated()), id: \.offset) { index, arrival in
                TrainArrivalListItem(trainArrival: arrival, curTime: date)
                    .padding(.top, index == 0 ? 0 : 4)
                    .padding(.bottom, index == arrivalsList.count - 1 ? 0 : 4)
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
