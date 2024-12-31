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
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var viewModel = ViewModel()
    
    @State private var showingFavoritesSheet = false
    
    @Query(filter: #Predicate<Station> { station in
        station.isSelected
    })  private var selectedStations: [Station]
    
    @State private var fetchTask: Task<Void, Never>?
    
    var body: some View {
        @Bindable var station: Station = selectedStations.first ?? Station.DEFAULT
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    StationRouteSymbols(station: station, routeSymbolSize: .large)
                    
                    if let lastUpdate = viewModel.lastUpdate {
                        // has loaded data
                        StationArrivalsView(downtownArrivals: viewModel.downtownArrivals, uptownArrivals: viewModel.uptownArrivals, lastUpdate: lastUpdate, queryStatus: $viewModel.queryStatus, isFetching: viewModel.numOngoingFetches > 0)
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .navigationTitle(station.name)
            .navigationBarTitleDisplayMode(.large)
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { station.isFavorite.toggle() }) {
                        Label("Add Station to Favorites", systemImage: station.isFavorite ? "star.fill" : "star")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingFavoritesSheet.toggle() }) {
                        Label("Select Favorite Station", systemImage: "tram.fill")
                    }
                    .sheet(isPresented: $showingFavoritesSheet) {
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
            .onChange(of: station, initial: true) { oldStation, newStation in
                fetchTask?.cancel()
                fetchTask = Task {
                    await startFetchingArrivals(for: newStation)
                }
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .background {
                    print("App in background -> cancelling task")
                    fetchTask?.cancel()
                } else if oldPhase == .background {
                    print("App not in background -> starting task")
                    fetchTask = Task {
                        await startFetchingArrivals(for: station)
                    }
                }
            }
            .onDisappear {
                fetchTask?.cancel()
            }
            .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
        }
    }
    
    private func startFetchingArrivals(for station: Station) async {
        print("====== BEGIN FETCH TASK FOR \(station.name)")
        do {
            print("@@ Initial update for \(station.name)")
            viewModel.updateArrivals(for: station)
            while !Task.isCancelled {
                print("@@ Fetching arrivals...")
                await viewModel.fetchArrivals()
                print("@@ Fetched arrivals")
                
                guard !Task.isCancelled else {
                    print("====== CANCEL FETCH TASK FOR \(station.name)")
                    break
                }
                
                viewModel.updateArrivals(for: station)
                print("@@ Updated arrivals for \(station.name)")
                
                guard !Task.isCancelled else {
                    print("====== CANCEL FETCH TASK FOR \(station.name)")
                    break
                }
                
                print("@@ Sleeping...")
                try await Task.sleep(for: .seconds(10))
            }
        } catch is CancellationError {
            print("====== CANCEL FETCH TASK FOR \(station.name)")
        } catch let error {
            print(error)
        }
    }
}

#Preview {
    ContentView()
}
