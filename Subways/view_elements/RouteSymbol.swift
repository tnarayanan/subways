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
            if route.rawValue.last! == "X" {
                Rectangle()
                    .fill(RouteSymbol.routeToColor(route: route))
                    .rotationEffect(Angle(degrees: 45))
                    .frame(width: size.rawValue, height: size.rawValue)
                    .scaleEffect(1 / sqrt(2))
            } else {
                Circle()
                    .fill(RouteSymbol.routeToColor(route: route))
                    .frame(width: size.rawValue, height: size.rawValue)
            }
            let routeStr: String = (route == .S || route == .FS) ? "S" : String(route.rawValue.first!)
            Text(routeStr)
                .font(Font.custom("Helvetica", size: size.rawValue / 1.5))
                .bold()
                .foregroundColor(RouteSymbol.routeToColor(route: route) == Color("subwayYellow") ? .black : .white)
        }
    }
    
    public static func routeToColor(route: Route) -> Color {
        return switch route {
        case .A, .C, .E:
            Color("subwayBlue")
        case .B, .D, .F, .F_EXPRESS, .M:
            Color("subwayOrange")
        case .G:
            Color("subwayLime")
        case .L:
            Color("subwayLightGray")
        case .J, .Z:
            Color("subwayBrown")
        case .N, .Q, .R, .W:
            Color("subwayYellow")
        case .ONE, .TWO, .THREE, .SI:
            Color("subwayRed")
        case .FOUR, .FIVE, .SIX, .SIX_EXPRESS:
            Color("subwayGreen")
        case .SEVEN, .SEVEN_EXPRESS:
            Color("subwayMagenta")
        case .T:
            Color("subwayTurquoise")
        case .S, .FS, .H, .X:
            Color("subwayGray")
        }
    }
}

enum RouteSymbolSize: CGFloat {
    case regular = 24 // 16 * 1.5
    case medium = 27 // 18 * 1.5
    case large = 33 // 20 * 1.5
}

#Preview {
    VStack(alignment: .leading) {
        RouteSymbol(route: .SIX_EXPRESS, size: .regular)
        RouteSymbol(route: .SIX, size: .regular)
    }.background(.red)
}
