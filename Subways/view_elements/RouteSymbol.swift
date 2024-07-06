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
    private let circleScale: CGFloat = 1.4
    
    var body: some View {
        //        Text(String(route.rawValue.first!))
        //            .font(Font.custom("Helvetica", size: size*3))
        //            .bold()
        //            .foregroundColor(routeToColor(route: route) == Color("subwayYellow") ? .black : .white)
        //            .padding(size)
        //            .background(routeToColor(route: route))
        //            .clipShape(Circle())
        ZStack {
            Circle().fill(routeToColor(route: route)).frame(width: size * circleScale, height: size * circleScale)
            Text(String(route.rawValue.first!))
                .font(Font.custom("Helvetica", size: size))
                .bold()
                .foregroundColor(routeToColor(route: route) == Color("subwayYellow") ? .black : .white)
//                .padding(size)
            
            
            
        }
    }
    
    private func routeToColor(route: Route) -> Color {
        return switch route {
        case .A, .C, .E:
            Color("subwayBlue")
        case .B, .D, .F, .M:
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
        case .FOUR, .FIVE, .SIX:
            Color("subwayGreen")
        case .SEVEN:
            Color("subwayMagenta")
        case .T:
            Color("subwayTurquoise")
        case .S, .FS, .H, .X:
            Color("subwayGray")
        }
    }
}

#Preview {
    RouteSymbol(route: .FOUR, size: 18)
}
