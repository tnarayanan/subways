//
//  RouteSymbol.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import SwiftUI

struct RouteSymbol: View {
    var route: Route
    var size: CGFloat
    private static let baseScale: CGFloat = 1.5
    
    var body: some View {
        ZStack {
            if route.rawValue.last! == "X" {
                Rectangle()
                    .fill(RouteSymbol.routeToColor(route: route))
                    .rotationEffect(Angle(degrees: 45))
                    .frame(width: size * RouteSymbol.baseScale, height: size * RouteSymbol.baseScale)
                    .scaleEffect(1 / sqrt(2))
            } else {
                Circle()
                    .fill(RouteSymbol.routeToColor(route: route))
                    .frame(width: size * RouteSymbol.baseScale, height: size * RouteSymbol.baseScale)
            }
            let routeStr: String = (route == .S || route == .FS) ? "S" : String(route.rawValue.first!)
            Text(routeStr)
                .font(Font.custom("Helvetica", size: size))
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

#Preview {
    VStack(alignment: .leading) {
        RouteSymbol(route: .SIX_EXPRESS, size: 18)
        RouteSymbol(route: .SIX, size: 18)
    }.background(.red)
}
