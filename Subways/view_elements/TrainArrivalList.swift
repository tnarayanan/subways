//
//  TrainArrivalList.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/8/24.
//

import SwiftUI

struct TrainArrivalList: View {
    @Environment(\.colorScheme) var colorScheme
    
    var arrivals: StationArrivals
    var direction: Direction
    var date: Date
    
    var body: some View {
        let groupBoxColor = colorScheme == .dark ? Color.systemGray6 : Color.white
        
        GroupBox {
            let arrivalsList: [TrainArrival] = direction == .DOWNTOWN ? arrivals.getDowntownArrivals() : arrivals.getUptownArrivals()
            let lastArrivalID: String = arrivalsList.last?.id ?? ""

            ForEach(arrivalsList) { arrival in
                TrainArrivalListItem(trainArrival: arrival, curTime: date)
                    .padding(.vertical, .extraSmall)
                if arrival.id != lastArrivalID {
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
