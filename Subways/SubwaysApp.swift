//
//  SubwaysApp.swift
//  Subways
//
//  Created by Tejas Narayanan on 7/4/24.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAppCheck

class SubwaysAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    return AppAttestProvider(app: app)
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let providerFactory = SubwaysAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)

        FirebaseApp.configure()
        return true
    }
}

@main
@MainActor
struct SubwaysApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {}
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .modelContainer(container)
    }
}
