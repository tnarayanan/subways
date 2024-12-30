//
//  Route.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation

enum Route: String, Identifiable, Comparable, Codable {
    static func < (lhs: Route, rhs: Route) -> Bool {
        let lhsColorHash = RouteSymbol.routeToColor(lhs).hashValue
        let rhsColorHash = RouteSymbol.routeToColor(rhs).hashValue
        
        if lhsColorHash == rhsColorHash {
            return lhs.rawValue < rhs.rawValue
        }
        return lhsColorHash < rhsColorHash
    }
    
    var id: String {
        return self.rawValue
    }
    
    case A, C, E, H, FS
    case B, D, F, F_EXPRESS = "FX", M
    case G
    case N, Q, R, W
    case L
    case ONE = "1", TWO = "2", THREE = "3", FOUR = "4", FIVE = "5", SIX = "6", SIX_EXPRESS = "6X", SEVEN = "7", SEVEN_EXPRESS = "7X", S = "GS"
    case SI
    case J, Z
    case T
    case X
}
