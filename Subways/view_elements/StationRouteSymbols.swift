//
//  StationRouteSymbols.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/7/24.
//

import SwiftUI

struct StationRouteSymbols: View {
    var station: Station
    var routeSymbolSize: RouteSymbolSize
    
    var body: some View {
        HStack {
            ForEach(station.routes.filter({ $0.rawValue.last != "X" }).sorted()) { route in
                RouteSymbol(route: route, size: routeSymbolSize)
                    .id(route.rawValue)
            }
        }
    }
}

#Preview {
    StationRouteSymbols(station: Station.get(id: "R30"), routeSymbolSize: .large)
}
