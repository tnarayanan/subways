//
//  SearchForStationView.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/7/24.
//

import SwiftUI
import SwiftData

struct SearchForStationView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) var modelContext
    
    @Bindable var selectedStation: Station
    
    @State private var searchText: String = ""
    
    @Query var allStations: [Station]
    
    var filteredStations: [Station] {
        if searchText.isEmpty {
            return allStations
        }
        return allStations.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        List {
            ForEach(filteredStations.sorted(), id: \.id) { station in
                VStack(alignment: .leading) {
                    Text(station.name)
                    StationRouteSymbols(station: station, routeSymbolSize: 18)
                }
                .id(station.id)
                .contentShape(Rectangle())
                .onTapGesture {
                    print("Switching to searched station '\(station.name)'")
                    selectedStation.isSelected = false
                    station.isSelected = true
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .contentMargins(.top, .zero)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for a station")
        .navigationTitle("All Stations")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

//#Preview {
//    SearchForStationView()
//}
