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
    
    var sortedStations: [Station] {
        favoriteStations.sorted()
    }
    
    var onDismiss: (String) -> Void = {_ in}
    
    var body: some View {
        NavigationView {
            VStack {
                if favoriteStations.isEmpty {
                    ContentUnavailableView("No favorite stations", systemImage: "star.fill", description: Text("Add stations to your favorites for quick access"))
                } else {
                    List {
                        ForEach(sortedStations, id: \.id) { station in
                            StationButton(station: station, action: {
                                print("Switching to favorite station '\(station.name)'")
                                selectedStation.isSelected = false
                                station.isSelected = true
                                dismiss()
                            })
                        }
                        .onDelete(perform: { indexSet in
                            for offset in indexSet {
                                let favStation = sortedStations[offset]
                                favStation.isFavorite = false
                                print("removed \(favStation.name) from favorites")
                            }
                        })
                    }
                    .contentMargins(.top, 4)
                }
            }
            .navigationTitle("Favorite Stations")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
