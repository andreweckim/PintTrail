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

    private var showScores: Bool {
        entries.count >= RankingEngine.scoreThreshold
    }

    private var topBeer: BeerEntry? {
        entries.max(by: { $0.eloRating < $1.eloRating })
    }

    private var eloMin: Double {
        entries.map(\.eloRating).min() ?? 1500
    }

    private var eloMax: Double {
        entries.map(\.eloRating).max() ?? 1500
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
                                    if showScores {
                                        PTScoreBadge(score: top.formattedDisplayScore(min: eloMin, max: eloMax))
                                    }
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
            .navigationBarHidden(true)
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
        .modelContainer(for: [BeerEntry.self, PubCrawl.self, CrawlCheckIn.self], inMemory: true)
}
