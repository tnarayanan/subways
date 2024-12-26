//
//  SubwaysApp.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import SwiftUI
import SwiftData

@main
struct SubwaysApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let stationConfig = ModelConfiguration(for: Station.self, isStoredInMemoryOnly: false)
//        let trainArrivalConfig = ModelConfiguration(for: TrainArrival.self, isStoredInMemoryOnly: true)
//
//        do {
//            return try ModelContainer(for: Station.self, TrainArrival.self, configurations: stationConfig, trainArrivalConfig)
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
    
    init() {
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Station.self, isAutosaveEnabled: false, isUndoEnabled: false)
    }
}
