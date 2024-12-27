//
//  SubwaysApp.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import SwiftUI
import SwiftData

@main
@MainActor
struct SubwaysApp: App {
    
    @MainActor
    let container: ModelContainer = {
        do {
            let container: ModelContainer = try ModelContainer(for: Station.self)
            let modelContext = ModelContext(container)
            
            // Initialize stations if necessary
            let stationCount = try modelContext.fetchCount(FetchDescriptor<Station>())
            if stationCount == 0 {
                print("Initializing station data")
                
                for station in Station.allStations.values {
                    station.isSelected = (station.stationId == "631") // default to Grand Central-42 St
                    modelContext.insert(station)
                }
                try modelContext.save()
            }
            
            // Delete all existing train arrivals
//            try modelContext.delete(model: TrainArrival.self)
//            try modelContext.save()
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {}

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
