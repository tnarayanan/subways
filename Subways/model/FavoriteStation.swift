//
//  Item.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import Foundation
import SwiftData

@Model
final class FavoriteStation: Equatable {
    @Attribute(.unique) var id: String
    
    init(id: String) {
        self.id = id
    }
    
    static func ==(lhs: FavoriteStation, rhs: FavoriteStation) -> Bool {
        return lhs.id == rhs.id
    }
}
