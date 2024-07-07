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
    @State private var stationID: String = "631"
    
    @State private var showingFavoritesSheet = false
    
    @State private var station: Station = Station.DEFAULT
    @State private var arrivals: StationArrivals = StationArrivals()
    
    private let routeSymbolSize: CGFloat = 20
    
    private let everySecondTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let updateDataTimer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
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
                await updateRoutes()
            }
        }
    }
    
    private func onStationSelected(id: String) {
        station = Station.get(id: id)
        arrivals = ArrivalDataProcessor.getArrivals(for: id)
    }
    
    private func onFavoriteTapped() {
        if station == Station.DEFAULT {
            return
        }
        if !favoriteStations.contains(FavoriteStation(id: stationID)) {
            // add to favorites
            modelContext.insert(FavoriteStation(id: stationID))
            print("Adding \(station.name) as a favorite station")
        } else {
            // unfavorite
            modelContext.delete(FavoriteStation(id: stationID))
            print("Removing \(station.name) from favorite stations")
        }
    }
    
    private func isCurrentStationFavorite() -> Bool {
        if station == Station.DEFAULT {
            return false
        }
        return favoriteStations.contains(FavoriteStation(id: stationID))
    }
    
    private func updateRoutes() async {
        await ArrivalDataProcessor.processArrivals()
        station = Station.get(id: stationID)
        arrivals = ArrivalDataProcessor.getArrivals(for: stationID)
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
