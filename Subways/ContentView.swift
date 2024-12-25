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
    
    @State private var date: Date = Date()
    
    @State private var showingFavoritesSheet = false
    
    @Query(filter: #Predicate<Station> { station in
        station.isSelected
    })  private var selectedStations: [Station]
    
    let userDefaults = UserDefaults.standard
    
    private let routeSymbolSize: CGFloat = 20
    private let defaultStation: String = "631" // default to Grand Central-42 St
    
    private let everySecondTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let updateDataTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        @Bindable var station: Station = selectedStations.first ?? Station.get(id: defaultStation)
//        @Bindable var station: Station = Station.get(id: defaultStation)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    StationRouteSymbols(station: station, routeSymbolSize: routeSymbolSize)
                    if station == Station.DEFAULT || (station.downtownArrivals.count + station.uptownArrivals.count) == 0 {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ProgressView("Loading data...")
                                Spacer()
                            }
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        Text("Downtown").font(.title3).bold()
                            .padding(.top)
                        
                        TrainArrivalList(station: station, direction: .DOWNTOWN, date: date)
                        
                        Text("Uptown").font(.title3).bold()
                            .padding(.top)
                        
                        TrainArrivalList(station: station, direction: .UPTOWN, date: date)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .navigationTitle(station.name)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            
            #if os(iOS)
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
            #endif
            .onReceive(everySecondTimer) { _ in
                self.date = Date()
            }
            .onReceive(updateDataTimer) { _ in
                Task {
                    await updateRoutes()
                }
            }
            .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground)) // Color.systemBackground : Color.secondarySystemBackground)
        }
        .onAppear {
            Task {
                await updateRoutes()
            }
        }
    }
    
    private func updateRoutes() async {
        await ArrivalDataProcessor.processArrivals(modelContext: modelContext)
    }
    
    private func addItem() {
        withAnimation {
            let newItem = FavoriteStation(id: "stationId")
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FavoriteStation.self, inMemory: true)
}
