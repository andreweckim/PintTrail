import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var entries: [BeerEntry]

    private var uniqueBreweries: Int {
        Set(entries.map(\.brewery).filter { !$0.isEmpty }).count
    }

    private var uniqueVenues: Int {
        Set(entries.compactMap(\.venueName)).count
    }

    private var averageRating: Double {
        guard !entries.isEmpty else { return 0 }
        return Double(entries.map(\.rating).reduce(0, +)) / Double(entries.count)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Your Stats") {
                    StatRow(label: "Beers Logged", value: "\(entries.count)")
                    StatRow(label: "Unique Breweries", value: "\(uniqueBreweries)")
                    StatRow(label: "Venues Visited", value: "\(uniqueVenues)")
                    StatRow(label: "Average Rating", value: String(format: "%.1f", averageRating))
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(.orange)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: BeerEntry.self, inMemory: true)
}
