//
//  Route.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation
import SwiftUI

enum Route: String, Identifiable, Comparable, Codable {
    static func < (lhs: Route, rhs: Route) -> Bool {
        return lhs.toGroup() < rhs.toGroup() || lhs.rawValue < rhs.rawValue
    }
    
    func toGroup() -> String {
        return switch self {
        case .A, .C, .E:
            "ACE"
        case .B, .D, .F, .F_EXPRESS, .M:
            "BDFM"
        case .G:
            "G"
        case .J, .Z:
            "JZ"
        case .N, .Q, .R, .W:
            "NQRW"
        case .ONE, .TWO, .THREE:
            "123"
        case .FOUR, .FIVE, .SIX, .SIX_EXPRESS:
            "456"
        case .SEVEN, .SEVEN_EXPRESS:
            "7"
        case .T:
            "T"
        default:
            "other"
        }
    }
    
    func toColor() -> Color {
        return switch self {
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
