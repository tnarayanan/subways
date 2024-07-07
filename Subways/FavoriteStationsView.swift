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
                        StationRouteSymbolsNonBinding(station: station, routeSymbolSize: 18)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("Switching to favorite station '\(station.name)'")
                        onDismiss(favStation.id)
                        dismiss()
                    }
                }
                .onDelete(perform: { indexSet in
                    for offset in indexSet {
                        let favStation = favoriteStations[offset]
                        modelContext.delete(favStation)
                    }
                })
            }
            .navigationTitle("Favorite Stations")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FavoriteStationsView()
}
