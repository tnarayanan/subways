//
//  TrainArrivalListItem.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import SwiftUI
import ActivityKit

struct TrainArrivalListItem: View {
    var trainArrival: TrainArrival
    var curTime: Date
    var showDivider: Bool
    
    @EnvironmentObject var viewModel: ViewModel
    
    @State private var hasActiveLiveActivity: Bool = false
    
    var body: some View {
        let diffs = Calendar.current.dateComponents([.minute, .second], from: curTime, to: trainArrival.time)
        VStack {
            HStack {
                RouteSymbol(route: trainArrival.route, size: .arrival)
                
                VStack(alignment: .leading) {
                    let minutes = diffs.minute ?? 0
                    let seconds = diffs.second ?? 0
                    let timeStr = minutes == 0 ? "\(abs(seconds)) sec" : "\(abs(minutes)) min \(abs(seconds)) sec"
                    
                    if (minutes >= 0 && seconds >= 0) {
                        Text("in \(timeStr)")
                            .monospacedDigit()
                    } else {
                        Text("\(timeStr) ago")
                            .monospacedDigit()
                            .foregroundStyle(Color.red)
                    }
                    
                    let arrivalTimeStr = trainArrival.time.formatted(date: .omitted, time: .shortened)
                    Text("\(arrivalTimeStr)")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: {
                    if hasActiveLiveActivity {
                        viewModel.removeLiveActivity(for: trainArrival)
                    } else {
                        viewModel.addLiveActivity(for: trainArrival)
                    }
                    hasActiveLiveActivity.toggle()
                }, label: {
                    if hasActiveLiveActivity {
                        Label("Remove live activity", systemImage: "clock.badge.fill").labelStyle(.iconOnly)
                    } else {
                        Label("Add live activity", systemImage: "clock.badge").labelStyle(.iconOnly)
                    }
                }).foregroundStyle(.secondary)
            }
            if showDivider {
                Divider()
            }
        }.onAppear {
            hasActiveLiveActivity = viewModel.getTrainArrivalTripIdsWithLiveActivities().contains(trainArrival.tripId)
        }.onChange(of: trainArrival) {
            hasActiveLiveActivity = viewModel.getTrainArrivalTripIdsWithLiveActivities().contains(trainArrival.tripId)
        }
    }
}

#Preview {
    TrainArrivalListItem(trainArrival: TrainArrival(tripId: "0001", route: .FOUR, direction: .DOWNTOWN, time: Date()), curTime: Date().addingTimeInterval(-168), showDivider: false)
        .padding()
    TrainArrivalListItem(trainArrival: TrainArrival(tripId: "0001", route: .FOUR, direction: .DOWNTOWN, time: Date()), curTime: Date().addingTimeInterval(62), showDivider: false)
        .padding()
}
