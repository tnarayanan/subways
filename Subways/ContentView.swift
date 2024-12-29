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
    
    @State private var showingFavoritesSheet = false
    
    @Query(filter: #Predicate<Station> { station in
        station.isSelected
    })  private var selectedStations: [Station]
    
    let userDefaults = UserDefaults.standard
    
    private let routeSymbolSize: CGFloat = 20
    
    private let everySecondTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let updateDataTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    @State private var lastUpdated: Date? = nil
    @State private var queryStatus: ArrivalQueryStatus = .SUCCESS
    private var arrivalDataProcessor: ArrivalDataProcessor = ArrivalDataProcessor()
    
    var body: some View {
        @Bindable var station: Station = selectedStations.first ?? Station.DEFAULT
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    StationRouteSymbols(station: station, routeSymbolSize: routeSymbolSize)
                    
                    if let lastUpdated {
                        // has loaded data
                        TimelineView(.periodic(from: .now, by: 1)) { timeline in
                            VStack(alignment: .leading) {
                                // lastUpdated string and query status
                                let diffs = Calendar.current.dateComponents([.second], from: lastUpdated, to: timeline.date)
                                Text("updated \(getStringFromSecondsAgo(diffs.second ?? 0))")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                QueryStatusLabel(queryStatus: $queryStatus)
                                
                                // train arrival lists
                                if horizontalSizeClass == .compact {
                                    TrainArrivalList(station: station, direction: .DOWNTOWN, date: timeline.date)
                                    TrainArrivalList(station: station, direction: .UPTOWN, date: timeline.date)
                                } else {
                                    HStack(alignment: .top) {
                                        TrainArrivalList(station: station, direction: .DOWNTOWN, date: timeline.date)
                                        TrainArrivalList(station: station, direction: .UPTOWN, date: timeline.date)
                                    }
                                }
                            }
                        }
                    } else {
                        // initially loading data
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ProgressView("Loading data...")
                                Spacer()
                            }
                            QueryStatusLabel(queryStatus: $queryStatus)
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)
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
            .onReceive(updateDataTimer) { _ in
                fetchArrivals(station: station)
            }
            .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
        }
        .onChange(of: station, initial: true) {
            updateArrivals(station: station)
            fetchArrivals(station: station)
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
        }
    }
    
    private func fetchArrivals(station: Station) {
        Task { @MainActor in
            let tmpQueryStatus = await arrivalDataProcessor.processArrivals(for: station.stationId)
            withAnimation(.easeOut(duration: 0.3)) {
                queryStatus = tmpQueryStatus
            }
            print("Fetched arrivals with status \(queryStatus)")
            if queryStatus == .SUCCESS {
                lastUpdated = Date()
            }
            updateArrivals(station: station)
        }
    }
}

#Preview {
    ContentView()
//        .modelContainer(for: FavoriteStation.self, inMemory: true)
}
