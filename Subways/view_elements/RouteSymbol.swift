//
//  RouteSymbol.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import SwiftUI

struct RouteSymbol: View {
    var route: Route
    var size: RouteSymbolSize
    
    var body: some View {
        ZStack {
            let routeColor = route.toColor()
            let routeStr: String = (route == .S || route == .FS) ? "S" : String(route.rawValue.first!)
            
            if route.rawValue.last! == "X" {
                Rectangle()
                    .fill(routeColor)
                    .rotationEffect(Angle(degrees: 45))
                    .frame(width: size.rawValue, height: size.rawValue)
                    .scaleEffect(1 / sqrt(2))
            } else {
                Circle()
                    .fill(routeColor)
                    .frame(width: size.rawValue, height: size.rawValue)
            }
            Text(routeStr)
                .font(Font.custom("Helvetica", size: size.rawValue / 1.5))
                .bold()
                .foregroundColor(routeColor == .subwayYellow ? .black : .white)
        }
    }
}

enum RouteSymbolSize: CGFloat {
    case arrival = 30
    case stationList = 27
    case stationHeader = 39
}

#Preview {
    VStack(alignment: .leading) {
        RouteSymbol(route: .SIX_EXPRESS, size: .arrival)
        RouteSymbol(route: .SIX, size: .arrival)
    }.background(.red)
    
    VStack {
        let routes: [Route] = [.ONE, .B, .N, .G, .FOUR, .SIX_EXPRESS, .T, .A, .SEVEN, .SEVEN_EXPRESS, .J, .S, .L]
        ForEach(routes) { route in
            HStack {
                RouteSymbol(route: route, size: .arrival)
                RouteSymbol(route: route, size: .stationList)
                RouteSymbol(route: route, size: .stationHeader)
            }
        }
    }
}
