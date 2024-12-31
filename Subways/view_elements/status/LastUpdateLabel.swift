//
//  LastUpdateLabel.swift
//  Subways
//
//  Created by Tejas Narayanan on 12/29/24.
//

import SwiftUI

struct LastUpdateLabel: View {
    var curDate: Date
    var lastUpdate: Date
    
    var body: some View {
        let diffs = Calendar.current.dateComponents([.second], from: lastUpdate, to: curDate)
        Text("updated \(getStringFromSecondsAgo(diffs.second ?? 0))")
            .font(.callout)
            .foregroundStyle(.secondary)
    }
    
    private func getStringFromSecondsAgo(_ secondsAgo: Int) -> String {
        if secondsAgo < 5 {
            return "just now"
        } else if secondsAgo < 10 {
            return "5 seconds ago"
        } else if secondsAgo < 60 {
            return "\((secondsAgo / 10) * 10) seconds ago"
        } else {
            return "more than a minute ago"
        }
    }
}

#Preview {
    let timeIntervals = [3, 5, 7, 10, 15, 25, 35, 45, 59, 60, 70]
    ForEach(timeIntervals, id: \.self) { timeInterval in
        HStack {
            Text("\(timeInterval)s")
            Spacer()
            LastUpdateLabel(curDate: Date(), lastUpdate: Date().addingTimeInterval(-Double(timeInterval)))
        }
    }.padding()
}

