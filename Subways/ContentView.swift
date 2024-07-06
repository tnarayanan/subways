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
    @Query private var items: [Item]
    
    @State private var date: Date = Date()
    @State private var station: Station = Station.get(id: "127")
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            List {
//                Section() {
//                    HStack {
//                        RouteSymbol(route: .FOUR, size: 16)
//                        RouteSymbol(route: .FIVE, size: 16)
//                        RouteSymbol(route: .SIX, size: 16)
//                        Spacer()
//                    }
//                    .listRowBackground(Color.clear)
//                }
                
                Section(Text("Downtown").font(.headline)) {
                    ForEach(station.arrivals.getDowntownArrivals()) { arrival in
                        TrainArrivalListItem(trainArrival: arrival, curTime: $date)
                    }
                }
                
                Section(Text("Uptown").font(.headline)) {
                    ForEach(station.arrivals.getUptownArrivals()) { arrival in
                        TrainArrivalListItem(trainArrival: arrival, curTime: $date)
                    }
                }
            }
            .navigationTitle(station.name)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        RouteSymbol(route: .FOUR, size: 16)
                        RouteSymbol(route: .FIVE, size: 16)
                        RouteSymbol(route: .SIX, size: 16)
                        Spacer()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .onReceive(timer) { _ in
                self.date = Date()
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
        Task {
            await ArrivalDataProcessor.processArrivals()
            station = Station.get(id: "127")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
