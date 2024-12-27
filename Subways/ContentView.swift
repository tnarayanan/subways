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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var date: Date = Date()
    
    @State private var showingFavoritesSheet = false
    
    @Query(filter: #Predicate<Station> { station in
        station.isSelected
    })  private var selectedStations: [Station]
    
    let userDefaults = UserDefaults.standard
    
    private let routeSymbolSize: CGFloat = 20
    
    private let everySecondTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let updateDataTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    @State private var lastUpdated: Date? = nil
    private var arrivalDataProcessor: ArrivalDataProcessor = ArrivalDataProcessor()
    
    var body: some View {
        @Bindable var station: Station = selectedStations.first ?? Station.DEFAULT
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    let loadingInitialData = station == Station.DEFAULT || (station.arrivals!.count) == 0
                    
                    HStack {
                        StationRouteSymbols(station: station, routeSymbolSize: routeSymbolSize)
                        // let lastUpdated = $station.lastUpdated.wrappedValue
                        if let lastUpdated {
                            if !loadingInitialData {
                                let diffs = Calendar.current.dateComponents([.second], from: lastUpdated, to: date)
                                Text("• updated \(getStringFromSecondsAgo(diffs.second ?? 0))")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                    if loadingInitialData {
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
                        if horizontalSizeClass == .compact {
                            Text("Downtown").font(.title3).bold()
                                .padding(.top)
                            
                            TrainArrivalList(station: station, direction: .DOWNTOWN, date: date)
                            
                            Text("Uptown").font(.title3).bold()
                                .padding(.top)
                            
                            TrainArrivalList(station: station, direction: .UPTOWN, date: date)
                        } else {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Downtown").font(.title3).bold()
                                        .padding(.top)
                                    
                                    TrainArrivalList(station: station, direction: .DOWNTOWN, date: date)
                                }
                                VStack(alignment: .leading) {
                                    Text("Uptown").font(.title3).bold()
                                        .padding(.top)
                                    
                                    TrainArrivalList(station: station, direction: .UPTOWN, date: date)
                                }
                            }
                        }
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
                fetchArrivals(station: station)
            }
            .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground)) // Color.systemBackground : Color.secondarySystemBackground)
        }
        .onAppear {
            fetchArrivals(station: station)
        }
        .onChange(of: station, initial: true) {
            updateArrivals(station: station)
        }
    }
    
    private func getStringFromSecondsAgo(_ secondsAgo: Int) -> String {
        if secondsAgo < 5 {
            return "just now"
        } else if secondsAgo < 10 {
            return "5 seconds ago"
        } else if secondsAgo < 60 {
            return "\((secondsAgo / 10) * 10) seconds ago"
        } else {
            return "more than a minute ago"
        }
    }
    
    private func updateArrivals(station: Station) {
        Task {
            let stationArrivalHeap = await arrivalDataProcessor.getArrivals(for: station.stationId)
            
            print("After retrieving arrivals")
            
            let oneMinuteAgo: Date = Date().addingTimeInterval(-60)
            var arrivalByTripId: [String: TrainArrival] = [:]
            
            for arrival in station.arrivals! {
                if arrival.time < oneMinuteAgo {
                    modelContext.delete(arrival)
                } else {
                    arrivalByTripId[arrival.tripId] = arrival
                }
            }
            
            print("Removed old arrivals")
            
            print(stationArrivalHeap)
            
            for direction in Direction.allCases {
                for newArrivalDTO in stationArrivalHeap[direction]!.unordered {
                    if let existingArrival = arrivalByTripId[newArrivalDTO.tripId] {
                        modelContext.delete(existingArrival)
                    }
                    let newArrival = TrainArrival(tripId: newArrivalDTO.tripId, route: newArrivalDTO.route, direction: newArrivalDTO.direction, time: newArrivalDTO.time)
                    modelContext.insert(newArrival)
                    newArrival.station = station
                }
            }
        }
    }
    
    private func fetchArrivals(station: Station) {
        Task {
            await arrivalDataProcessor.processArrivals(for: station.stationId)
            print("Fetched arrivals")
            lastUpdated = Date()
            updateArrivals(station: station)
        }
    }
}

#Preview {
    ContentView()
//        .modelContainer(for: FavoriteStation.self, inMemory: true)
}
