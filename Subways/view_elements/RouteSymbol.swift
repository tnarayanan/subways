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
            let routeColor = RouteSymbol.routeToColor(route)
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
    
    public static func routeToColor(_ route: Route) -> Color {
        return switch route {
        case .A, .C, .E:
                .subwayBlue
        case .B, .D, .F, .F_EXPRESS, .M:
                .subwayOrange
        case .G:
                .subwayLime
        case .L:
                .subwayLightGray
        case .J, .Z:
                .subwayBrown
        case .N, .Q, .R, .W:
                .subwayYellow
        case .ONE, .TWO, .THREE, .SI:
                .subwayRed
        case .FOUR, .FIVE, .SIX, .SIX_EXPRESS:
                .subwayGreen
        case .SEVEN, .SEVEN_EXPRESS:
                .subwayMagenta
        case .T:
                .subwayTurquoise
        case .S, .FS, .H, .X:
                .subwayGray
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
