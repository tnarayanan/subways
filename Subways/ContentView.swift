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
    
    @StateObject private var viewModel = ViewModel()
    
    @State private var showingFavoritesSheet = false
    
    @Query(filter: #Predicate<Station> { station in
        station.isSelected
    })  private var selectedStations: [Station]
    
    var body: some View {
        @Bindable var station: Station = selectedStations.first ?? Station.DEFAULT
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    StationRouteSymbols(station: station, routeSymbolSize: .large)
                    
                    if let lastUpdate = viewModel.lastUpdate {
                        // has loaded data
                        StationArrivalsView(downtownArrivals: viewModel.downtownArrivals, uptownArrivals: viewModel.uptownArrivals, lastUpdate: lastUpdate, queryStatus: $viewModel.queryStatus)
                    } else {
                        // initially loading data
                        VStack(alignment: .center) {
                            Spacer()
                            ProgressView("Loading data...")
                            QueryStatusLabel(queryStatus: $viewModel.queryStatus)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .task(id: station) {
                    // fetch arrivals every 10 seconds
                    repeat {
                        await viewModel.fetchArrivals()
                        viewModel.updateArrivals(for: station)
                        
                        try? await Task.sleep(for: .seconds(10))
                    } while !Task.isCancelled
                }
                .onChange(of: station, initial: true) {
                    viewModel.updateArrivals(for: station)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
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
}
