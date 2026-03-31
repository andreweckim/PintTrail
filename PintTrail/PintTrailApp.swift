import SwiftUI
import SwiftData

@main
struct PintTrailApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: BeerEntry.self)
    }
}
