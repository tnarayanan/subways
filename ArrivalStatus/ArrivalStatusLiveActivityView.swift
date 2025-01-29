//
//  ArrivalStatusLiveActivityView.swift
//  ArrivalStatusExtension
//
//  Created by Tejas Narayanan on 1/15/25.
//

import SwiftUI
import WidgetKit

struct ArrivalStatusLiveActivityView: View {
    let context: ActivityViewContext<ArrivalStatusAttributes>
    
    init(_ context: ActivityViewContext<ArrivalStatusAttributes>) {
        self.context = context
    }
    
    var body: some View {
        let stationName: String = context.attributes.stationName
        let route: Route = context.attributes.route
        let direction: Direction = context.attributes.direction
        let arrivalTime: Date = context.state.arrivalTime
        
        VStack(alignment: .leading) {
            Text("\(direction.rawValue) • \(stationName)")
                .font(.callout)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            HStack {
                RouteSymbol(route: route, size: .stationHeader)
                if Date() > arrivalTime {
                    Text(TimeDataSource<Date>.currentDate, format: .timer(countingUpIn:arrivalTime..<arrivalTime.addingTimeInterval(60)))
                        .font(.title2)
                        .monospacedDigit()
                        .foregroundStyle(.red)
                    Text(" ago")
                        .font(.title2)
                        .padding(.trailing, 0)
                        .foregroundStyle(.red)
                } else {
                    Text(" in")
                        .font(.title2)
                        .padding(.trailing, 0)
                    Text(TimeDataSource<Date>.currentDate, format: .timer(countingDownIn:Date.now..<arrivalTime))
                        .font(.title2)
                        .monospacedDigit()
                }

                let arrivalTimeStr = arrivalTime.formatted(date: .omitted, time: .shortened)
                Text("  \(arrivalTimeStr)")
                    .font(.title2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }
}

//#Preview {
//    ArrivalStatusLiveActivityView()
//}
