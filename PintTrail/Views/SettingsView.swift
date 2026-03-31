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
            ZStack {
                PTTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Stats
                        VStack(spacing: 0) {
                            PTSectionHeader(title: "Your Stats")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 12)

                            VStack(spacing: 0) {
                                SettingsStatRow(label: "Beers Logged", value: "\(entries.count)")
                                Divider().overlay(PTTheme.surfaceLight)
                                SettingsStatRow(label: "Unique Breweries", value: "\(uniqueBreweries)")
                                Divider().overlay(PTTheme.surfaceLight)
                                SettingsStatRow(label: "Venues Visited", value: "\(uniqueVenues)")
                            }
                            .ptCard()
                        }

                        if let top = topBeer, entries.count > 1 {
                            VStack(spacing: 0) {
                                PTSectionHeader(title: "Top Beer")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom, 12)

                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(top.name)
                                            .font(.headline)
                                            .foregroundStyle(PTTheme.cream)
                                        if !top.brewery.isEmpty {
                                            Text(top.brewery)
                                                .font(.caption)
                                                .foregroundStyle(PTTheme.creamDim)
                                        }
                                    }
                                    Spacer()
                                    PTScoreBadge(score: top.formattedScore(outOf: entries.count))
                                }
                                .padding()
                                .ptCard()
                            }
                        }

                        // About
                        VStack(spacing: 0) {
                            PTSectionHeader(title: "About")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 12)

                            HStack {
                                Text("Version")
                                    .foregroundStyle(PTTheme.cream)
                                Spacer()
                                Text("1.0.0")
                                    .foregroundStyle(PTTheme.creamDim)
                            }
                            .padding()
                            .ptCard()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(PTTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}

struct SettingsStatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(PTTheme.cream)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(PTTheme.amber)
        }
        .padding()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: BeerEntry.self, inMemory: true)
}
