import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .journal

    enum Tab {
        case journal, crawls, map, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.closed")
                }
                .tag(Tab.journal)

            CrawlsView()
                .tabItem {
                    Label("Crawls", systemImage: "figure.walk")
                }
                .tag(Tab.crawls)

            MapTabView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(Tab.map)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
        .tint(PTTheme.amber)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [BeerEntry.self, PubCrawl.self, CrawlCheckIn.self], inMemory: true)
}
