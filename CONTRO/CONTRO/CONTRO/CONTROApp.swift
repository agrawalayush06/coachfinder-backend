//
//  CONTROApp.swift
//  SplitEase
//
//  Created for SplitEase.
//

import SwiftUI
import SwiftData

@main
struct CONTROApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                SDUser.self,
                SDGroup.self,
                SDExpense.self,
                SDSplitItem.self,
                SDSettlement.self,
                SDActivity.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])

            // Seed demo data on initial launch
            let context = ModelContext(container)
            SeedDataLoader.loadSampleData(modelContext: context)
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
