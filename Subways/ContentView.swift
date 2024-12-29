//
//  ContentView.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingFavoritesSheet = false
    
    @Query(filter: #Predicate<Station> { station in
        station.isSelected
    })  private var selectedStations: [Station]
    
    @State private var lastUpdate: Date? = nil
    
    @State private var queryStatus: ArrivalQueryStatus = .SUCCESS
    private var arrivalDataProcessor: ArrivalDataProcessor = ArrivalDataProcessor()
    
    var body: some View {
        @Bindable var station: Station = selectedStations.first ?? Station.DEFAULT
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    StationRouteSymbols(station: station, routeSymbolSize: .large)
                    
                    if let lastUpdate {
                        // has loaded data
                        StationArrivalsView(station: station, lastUpdate: lastUpdate, queryStatus: $queryStatus)
                    } else {
                        // initially loading data
                        VStack(alignment: .center) {
                            Spacer()
                            ProgressView("Loading data...")
                            QueryStatusLabel(queryStatus: $queryStatus)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .task {
                // fetch arrivals every 10 seconds
                repeat {
                    fetchArrivals(for: station)
                    try? await Task.sleep(for: .seconds(10))
                } while (!Task.isCancelled)
            }
            .onChange(of: station) {
                let oldLastUpdate: Date? = lastUpdate
                lastUpdate = nil
                updateArrivalsData(for: station, newLastUpdate: oldLastUpdate)
                fetchArrivals(for: station)
            }
            
            // title and toolbar
            .navigationTitle(station.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        station.isFavorite.toggle()
                    }
                    label: {
                        Label("Add Station to Favorites", systemImage: station.isFavorite ? "star.fill" : "star")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingFavoritesSheet.toggle()
                    }
                    label: {
                        Label("Select Favorite Station", systemImage: "tram.fill")
                    }
                    .sheet(isPresented: $showingFavoritesSheet, onDismiss: {
                        print("dismissed sheet")
                    }) {
                        FavoriteStationsView(selectedStation: station)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SearchForStationView(selectedStation: station)
                    }
                    label: {
                        Label("Select Station", systemImage: "magnifyingglass")
                    }
                }
            }
            .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
        }
    }
    
    private func updateArrivalsData(for station: Station, newLastUpdate: Date?) {
        Task { @MainActor in
            let stationArrivalHeap = await arrivalDataProcessor.getArrivals(for: station.stationId)
            
            print("After retrieving arrivals")
            print("\(station.arrivals!.count) existing arrivals")
            
            for arrival in station.arrivals! {
                modelContext.delete(arrival)
            }
            
            print("Removed old arrivals")
            print(stationArrivalHeap)
            
            for direction in Direction.allCases {
                for newArrivalDTO in stationArrivalHeap[direction]!.unordered {
                    let newArrival = TrainArrival(tripId: newArrivalDTO.tripId, route: newArrivalDTO.route, direction: newArrivalDTO.direction, time: newArrivalDTO.time)
                    modelContext.insert(newArrival)
                    newArrival.station = station
                }
            }
            
            lastUpdate = newLastUpdate
        }
    }
    
    private func fetchArrivals(for station: Station) {
        Task { @MainActor in
            let tmpQueryStatus = await arrivalDataProcessor.processArrivals()
            withAnimation(.easeOut(duration: 0.3)) {
                queryStatus = tmpQueryStatus
            }
            print("Fetched arrivals with status \(queryStatus)")
            if queryStatus == .SUCCESS {
                updateArrivalsData(for: station, newLastUpdate: Date())
            }
        }
    }
}
