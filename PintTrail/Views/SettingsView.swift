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

    private var topBeer: BeerEntry? {
        entries.min(by: { $0.rankPosition < $1.rankPosition })
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Your Stats") {
                    StatRow(label: "Beers Logged", value: "\(entries.count)")
                    StatRow(label: "Unique Breweries", value: "\(uniqueBreweries)")
                    StatRow(label: "Venues Visited", value: "\(uniqueVenues)")
                }

                if let top = topBeer, entries.count > 1 {
                    Section("Top Beer") {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(top.name)
                                    .font(.headline)
                                if !top.brewery.isEmpty {
                                    Text(top.brewery)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Text(top.formattedScore(outOf: entries.count))
                                .font(.title2.bold())
                                .foregroundStyle(.orange)
                        }
                    }
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
