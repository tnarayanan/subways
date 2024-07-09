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
            ForEach(filteredStations) { station in
                VStack {
                    HStack {
                        Text(station.name)
                        Spacer()
                    }
                    StationRouteSymbols(station: station, routeSymbolSize: 18)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    print("Switching to searched station '\(station.name)'")
                    selectedStation.isSelected = false
                    station.isSelected = true
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search for a station")
        .navigationTitle("Search for Station")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .onAppear {
                if allStations.isEmpty {
                    Station.addAllStationsTo(modelContext: modelContext)
                }
            }
    }
}

//#Preview {
//    SearchForStationView()
//}
