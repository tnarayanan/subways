//
//  ArrivalStatusLiveActivity.swift
//  ArrivalStatus
//
//  Created by Tejas Narayanan on 1/14/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ArrivalStatusAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var arrivalTime: Date
    }

    // Fixed non-changing properties about your activity go here!
    var stationName: String
    var direction: Direction
    var route: Route
    
}

struct ArrivalStatusLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ArrivalStatusAttributes.self) { context in
            // Lock screen/banner UI goes here
            ArrivalStatusLiveActivityView(context)
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    ArrivalStatusLiveActivityView(context)
                    .dynamicIsland(verticalPlacement: .belowIfTooWide)                }
            } compactLeading: {
                RouteSymbol(route: context.attributes.route, size: .stationList)
            } compactTrailing: {
                let arrivalTime: Date = context.state.arrivalTime
                
                /*let diffs = Calendar.current.dateComponents([.minute, .second], from: Date(), to: arrivalTime)
                
                let minutes = diffs.minute ?? 0
                let seconds = diffs.second ?? 0
                let timeStr = minutes == 0 ? "\(abs(seconds))s" : "\(abs(minutes))m\(abs(seconds))s"
                Text(" \(timeStr)")
                    .monospacedDigit()
                    .foregroundStyle(minutes >= 0 && seconds >= 0 ? .primary : Color.red)
                    .onReceive(timer) { newTime in
                        curTime = newTime
                    }*/
                Text("11:11").monospacedDigit()
                    .hidden()
                    .overlay(alignment: .leading) {
                        Text(TimeDataSource<Date>.currentDate, format: .timer(countingDownIn:Date.now..<arrivalTime))
                            .monospacedDigit()
                    }
//                    .foregroundStyle(minutes >= 0 && seconds >= 0 ? .primary : Color.red)
            } minimal: {
                RouteSymbol(route: context.attributes.route, size: .stationList)
            }
        }
    }
}

extension ArrivalStatusAttributes {
    fileprivate static var preview: ArrivalStatusAttributes {
        ArrivalStatusAttributes(stationName: "Grand Central - 42 St", direction: .DOWNTOWN, route: .SIX)
    }
}

extension ArrivalStatusAttributes.ContentState {
    fileprivate static var tenMinutesFortyFiveSeconds: ArrivalStatusAttributes.ContentState {
        ArrivalStatusAttributes.ContentState(arrivalTime: Date().addingTimeInterval(645))
    }
    fileprivate static var oneMinuteFortyFiveSeconds: ArrivalStatusAttributes.ContentState {
        ArrivalStatusAttributes.ContentState(arrivalTime: Date().addingTimeInterval(105))
    }
    fileprivate static var fortyFiveSeconds: ArrivalStatusAttributes.ContentState {
        ArrivalStatusAttributes.ContentState(arrivalTime: Date().addingTimeInterval(45))
    }
    fileprivate static var fortyFourSeconds: ArrivalStatusAttributes.ContentState {
        ArrivalStatusAttributes.ContentState(arrivalTime: Date().addingTimeInterval(44))
    }
    fileprivate static var twoSeconds: ArrivalStatusAttributes.ContentState {
        ArrivalStatusAttributes.ContentState(arrivalTime: Date().addingTimeInterval(2))
    }
    fileprivate static var now: ArrivalStatusAttributes.ContentState {
        ArrivalStatusAttributes.ContentState(arrivalTime: Date())
    }
    fileprivate static var oneSecondAgo: ArrivalStatusAttributes.ContentState {
        ArrivalStatusAttributes.ContentState(arrivalTime: Date().addingTimeInterval(-1))
    }
}

//#Preview("Notification", as: .content, using: ArrivalStatusAttributes.preview) {
//#Preview("Notification", as: .dynamicIsland(.expanded), using: ArrivalStatusAttributes.preview) {
//#Preview("Notification", as: .dynamicIsland(.compact), using: ArrivalStatusAttributes.preview) {
#Preview("Notification", as: .dynamicIsland(.minimal), using: ArrivalStatusAttributes.preview) {
   ArrivalStatusLiveActivity()
} contentStates: {
    ArrivalStatusAttributes.ContentState.tenMinutesFortyFiveSeconds;
    ArrivalStatusAttributes.ContentState.oneMinuteFortyFiveSeconds;
    ArrivalStatusAttributes.ContentState.fortyFiveSeconds;
    ArrivalStatusAttributes.ContentState.fortyFourSeconds;
    ArrivalStatusAttributes.ContentState.twoSeconds;
    ArrivalStatusAttributes.ContentState.now;
    ArrivalStatusAttributes.ContentState.oneSecondAgo;
}
