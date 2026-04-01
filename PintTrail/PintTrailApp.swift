import SwiftUI
import SwiftData

@main
struct PintTrailApp: App {
    let container: ModelContainer

    init() {
        let container = try! ModelContainer(for: BeerEntry.self, PubCrawl.self, CrawlCheckIn.self)
        self.container = container
        TestData.seedIfEmpty(context: container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
