//
//  SearchForStationView.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/7/24.
//

import SwiftUI

struct SearchForStationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var searchText: String = ""
    var onDismiss: (String) -> Void = {_ in}
    
    var filteredStations: [Station] {
        if searchText.isEmpty {
            return Array(Station.allStations.values)
        }
        return Station.allStations.values.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        List {
            ForEach(filteredStations) { station in
                VStack {
                    HStack {
                        Text(station.name)
                        Spacer()
                    }
                    StationRouteSymbolsNonBinding(station: station, routeSymbolSize: 18)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    print("Switching to searched station '\(station.name)'")
                    onDismiss(station.id)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search for a station")
        .navigationTitle("Search for Station")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    SearchForStationView()
}
