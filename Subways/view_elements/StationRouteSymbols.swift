//
//  StationRouteSymbols.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/7/24.
//

import SwiftUI

struct StationRouteSymbols: View {
    var station: Station
    var routeSymbolSize: CGFloat
    
    var body: some View {
        HStack {
            ForEach(station.routes.filter({ $0.rawValue.last != "X" }).sorted()) { route in
                RouteSymbol(route: route, size: routeSymbolSize)
            }
        }
    }
}

//#Preview {
//    StationRouteSymbols(station: Station.get(id: "127"), routeSymbolSize: 18)
//}
