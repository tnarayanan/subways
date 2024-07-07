//
//  ContentView.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import SwiftUI
import SwiftUIX
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var favoriteStations: [FavoriteStation]
    
    @State private var date: Date = Date()
    
    @State private var showingFavoritesSheet = false
    
    @State private var station: Station = Station.DEFAULT
    @State private var arrivals: StationArrivals = StationArrivals()
    
    let userDefaults = UserDefaults.standard
    
    private let routeSymbolSize: CGFloat = 20
    private let defaultStation: String = "631" // default to Grand Central-42 St
    
    private let everySecondTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let updateDataTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    init() {
        if getSelectedStationId() == nil {
            setSelectedStationId(defaultStation)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    StationRouteSymbols(station: $station, routeSymbolSize: routeSymbolSize)
                    
                    Text("Downtown").font(.title3).bold()
                        .padding(.top)
                    
                    GroupBox {
                        let lastArrival = arrivals.getDowntownArrivals().last
                        let lastID = lastArrival?.id ?? ""
                        ForEach(arrivals.getDowntownArrivals()) { arrival in
                            TrainArrivalListItem(trainArrival: arrival, curTime: $date)
                                .padding(.vertical, .extraSmall)
                            if arrival.id != lastID {
                                Divider()
                            }
                        }
                    }
                    .backgroundStyle(Color.white)
                    
                    Text("Uptown").font(.title3).bold()
                        .padding(.top)
                    
                    GroupBox {
                        let lastArrival = arrivals.getUptownArrivals().last
                        let lastID = lastArrival?.id ?? ""
                        ForEach(arrivals.getUptownArrivals()) { arrival in
                            TrainArrivalListItem(trainArrival: arrival, curTime: $date)
                                .padding(.vertical, .extraSmall)
                            if arrival.id != lastID {
                                Divider()
                            }
                        }
                    }
                    .backgroundStyle(Color.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .navigationTitle(station.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onFavoriteTapped) {
                        Label("Add Station to Favorites", systemImage: isCurrentStationFavorite() ? "star.fill" : "star")
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
                        FavoriteStationsView(onDismiss: self.onStationSelected)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SearchForStationView(onDismiss: self.onStationSelected)
                    }
                    label: {
                        Label("Select Station", systemImage: "magnifyingglass")
                    }
                }
            }
            .onReceive(everySecondTimer) { _ in
                self.date = Date()
            }
            .onReceive(updateDataTimer) { _ in
                Task {
                    await updateRoutes()
                }
            }
            .background(Color.secondarySystemBackground)
        }
        .onAppear {
            Task {
                station = Station.get(id: getSelectedStationId() ?? defaultStation)
                await updateRoutes()
            }
        }
    }
    
    private func getSelectedStationId() -> String? {
        return userDefaults.string(forKey: "selectedStationId")
    }
    
    private func setSelectedStationId(_ id: String) {
        userDefaults.set(id, forKey: "selectedStationId")
    }
    
    private func onStationSelected(id: String) {
        setSelectedStationId(id)
        station = Station.get(id: id)
        arrivals = ArrivalDataProcessor.getArrivals(for: id)
    }
    
    private func onFavoriteTapped() {
        if station == Station.DEFAULT {
            return
        }
        for favStation in favoriteStations {
            if station.id == favStation.id {
                modelContext.delete(favStation)
                print("Removing \(station.name) from favorite stations")
                return
            }
        }
        modelContext.insert(FavoriteStation(id: station.id))
        print("Adding \(station.name) as a favorite station")
    }
    
    private func isCurrentStationFavorite() -> Bool {
        if station == Station.DEFAULT {
            return false
        }
        return favoriteStations.contains(FavoriteStation(id: station.id))
    }
    
    private func updateRoutes() async {
        await ArrivalDataProcessor.processArrivals()
        arrivals = ArrivalDataProcessor.getArrivals(for: station.id)
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
