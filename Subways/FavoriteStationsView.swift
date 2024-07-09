//
//  FavoriteStationsView.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/7/24.
//

import SwiftUI
import SwiftData

struct FavoriteStationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Bindable var selectedStation: Station
    
    @Query(filter: #Predicate<Station> { station in
        station.isFavorite
    }) private var favoriteStations: [Station]
    
    var onDismiss: (String) -> Void = {_ in}
    
    var body: some View {
        NavigationView {
            List {
                ForEach(favoriteStations) { station in
                    VStack {
                        HStack {
                            Text(station.name)
                            Spacer()
                        }
                        StationRouteSymbols(station: station, routeSymbolSize: 18)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("Switching to favorite station '\(station.name)'")
                        selectedStation.isSelected = false
                        station.isSelected = true
                        dismiss()
                    }
                }
                .onDelete(perform: { indexSet in
                    for offset in indexSet {
                        let favStation = favoriteStations[offset]
                        favStation.isFavorite = false
                    }
                })
            }
            .navigationTitle("Favorite Stations")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

//#Preview {
//    FavoriteStationsView()
//}
