//
//  MediaTimeApp.swift
//  MediaTime
//
//  Created by Brice Dickerson on 7/29/25.
//

import SwiftUI
import SwiftData
import ActivityKit

@main
struct MediaTimeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TimeSession.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleLiveActivityInteraction(url: url)
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func handleLiveActivityInteraction(url: URL) {
        // Handle LiveActivity interaction
        print("LiveActivity interaction received: \(url)")
        
        // Check if this is a MediaTime LiveActivity interaction
        if url.scheme == "mediatime" || url.host == "liveactivity" {
            // Handle the LiveActivity interaction
            ContentView.handleLiveActivityInteraction()
        }
    }
}
