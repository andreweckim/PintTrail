import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .journal

    enum Tab {
        case journal, map, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.closed")
                }
                .tag(Tab.journal)

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
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BeerEntry.self, inMemory: true)
}
