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
                Text(" in")
                    .font(.title2)
                    .padding(.trailing, 0)
            
//                    Text(TimeDataSource<Date>.durationOffset(to: arrivalTime), format: .units(allowed: [.minutes, .seconds], width: .abbreviated, fractionalPart: .hide(rounded: .down)))
//                    Text(TimeDataSource<Date>.currentDate, format: .offset(to: arrivalTime, allowedFields: [.minute, .second], sign: .never))
//                    Text(TimeDataSource<Date>.currentDate, format: .reference(to: arrivalTime, allowedFields: [.minute, .second]))
                Text(TimeDataSource<Date>.currentDate, format: .timer(countingDownIn:Date.now..<arrivalTime)) // ****
//                    Text(TimeDataSource<Date>.currentDate, format: .timer(countingDownIn: Date.now..<arrivalTime, showHours: false))
//                    Text(TimeDataSource<Date>.durationOffset(to: arrivalTime), format: .units(allowed: [.minutes, .seconds], width: .abbreviated, fractionalPart: .hide(rounded: .down)))
//                        .font(.title2)
//                        .monospacedDigit()
//                    timeRemainingText(curTime: TimeDataSource.currentDate, arrivalTime: arrivalTime)
//                    Text(timerInterval: TimeDataSource<Date>.dateRange(endingAt: arrivalTime), pauseTime: arrivalTime, showsHours: false)
                    .font(.title2)
                    .monospacedDigit()
                
                let arrivalTimeStr = arrivalTime.formatted(date: .omitted, time: .shortened)
                Text("  \(arrivalTimeStr)")
                    .font(.title2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }
    
//    func timeRemainingText(curTime: Date, arrivalTime: Date) -> Text {
//        let diffs = Calendar.current.dateComponents([.minute, .second], from: curTime, to: arrivalTime)
//        
//        let minutes = diffs.minute ?? 0
//        let seconds = diffs.second ?? 0
//        let timeStr = minutes == 0 ? "\(abs(seconds)) sec" : "\(abs(minutes)) min \(abs(seconds)) sec"
//    
//        if (minutes >= 0 && seconds >= 0) {
//            return Text(" in \(timeStr)")
//                .font(.title2)
//                .monospacedDigit()
//        } else {
//            return Text(" \(timeStr) ago")
//                .monospacedDigit()
//                .font(.title2)
//                .foregroundStyle(Color.red)
//        }
//    }
}

//#Preview {
//    ArrivalStatusLiveActivityView()
//}
