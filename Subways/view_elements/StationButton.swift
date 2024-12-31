//
//  StationButton.swift
//  Subways
//
//  Created by Tejas Narayanan on 12/30/24.
//

import SwiftUI

struct StationButton: View {
    var station: Station
    var action: () -> Void
    
    init(station: Station, action: @escaping @MainActor () -> Void) {
        self.station = station
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                Text(station.name)
                HStack {
                    StationRouteSymbols(station: station, routeSymbolSize: .medium)
                    Spacer()
                }
            }
            .id(station.id)
            .contentShape(Rectangle())
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    StationButton(station: Station.get(id: "R30"), action: {})
}
