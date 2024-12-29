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
        
        VStack(alignment: .leading) {
            Text(direction.rawValue.capitalized(with: nil)).font(.title3).bold()
                .padding(.top)
            
            GroupBox {
                let arrivalsList: [TrainArrival] = station.arrivals!.filter { $0.direction == direction }
                
                if arrivalsList.count == 0 {
                    HStack {
                        Text("No arrivals found")
                        Spacer()
                    }
                } else {
                    ForEach(Array(arrivalsList.sorted().enumerated()), id: \.offset) { index, arrival in
                        TrainArrivalListItem(trainArrival: arrival, curTime: date)
                            .padding(.top, index == 0 ? 0 : 4)
                            .padding(.bottom, index == arrivalsList.count - 1 ? 0 : 4)
                        if index != arrivalsList.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .backgroundStyle(groupBoxColor)
    }
}

//#Preview {
//    TrainArrivalList()
//}
