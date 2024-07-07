//
//  FavoriteStationsView.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/7/24.
//

import SwiftUI
import SwiftData

struct FavoriteStationsView: View {
    @Environment(\.dismiss) var dismiss
    
    @Query private var favoriteStations: [FavoriteStation]
    
    var onDismiss: (String) -> Void = {_ in}
    
    var body: some View {
        NavigationView {
            List {
                ForEach(favoriteStations) { favStation in
                    let station: Station = Station.get(id: favStation.id)
                    VStack {
                        HStack {
                            Text(station.name)
                            Spacer()
                        }
                        HStack {
                            ForEach(station.routes.filter({ $0.rawValue.last != "X" }).sorted()) { route in
                                RouteSymbol(route: route, size: 18)
                            }
                            Spacer()
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print(station.name)
                        onDismiss(favStation.id)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Favorite Stations")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FavoriteStationsView()
}
