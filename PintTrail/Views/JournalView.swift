import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BeerEntry.eloRating, order: .reverse) private var entries: [BeerEntry]
    @State private var showingAddEntry = false
    @State private var sortByRank = true

    private var sortedEntries: [BeerEntry] {
        if sortByRank {
            return entries
        } else {
            return entries.sorted { $0.createdAt > $1.createdAt }
        }
    }

    private var showScores: Bool {
        entries.count >= RankingEngine.scoreThreshold
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

                if entries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "mug")
                            .font(.system(size: 48))
                            .foregroundStyle(PTTheme.amber.opacity(0.4))
                        Text("No Beers Yet")
                            .font(.title2.bold())
                            .foregroundStyle(PTTheme.cream)
                        Text("Log your first beer to start your trail")
                            .font(.subheadline)
                            .foregroundStyle(PTTheme.creamDim)

                        Button(action: { showingAddEntry = true }) {
                            Label("Log a Beer", systemImage: "plus")
                                .font(.subheadline.bold())
                                .foregroundStyle(PTTheme.stout)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(PTTheme.amber)
                                .clipShape(Capsule())
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            // Inline toolbar
                            HStack {
                                Menu {
                                    Button {
                                        sortByRank = true
                                    } label: {
                                        Label("By Ranking", systemImage: sortByRank ? "checkmark" : "")
                                    }
                                    Button {
                                        sortByRank = false
                                    } label: {
                                        Label("By Date", systemImage: sortByRank ? "" : "checkmark")
                                    }
                                } label: {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .font(.body)
                                        .foregroundStyle(PTTheme.amber)
                                }

                                Spacer()

                                Button(action: { showingAddEntry = true }) {
                                    Image(systemName: "plus")
                                        .font(.body)
                                        .foregroundStyle(PTTheme.amber)
                                }
                            }
                            .padding(.horizontal, 4)

                            ForEach(Array(sortedEntries.enumerated()), id: \.element.id) { index, entry in
                                let rank = (entries.firstIndex(where: { $0.id == entry.id }) ?? index) + 1
                                NavigationLink(destination: BeerDetailView(entry: entry, rank: rank, totalEntries: entries.count, showScore: showScores, eloMin: eloMin, eloMax: eloMax)) {
                                    BeerCard(entry: entry, rank: rank, totalEntries: entries.count, showScore: showScores, eloMin: eloMin, eloMax: eloMax)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddEntry) {
                AddBeerView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct BeerCard: View {
    let entry: BeerEntry
    let rank: Int
    let totalEntries: Int
    let showScore: Bool
    let eloMin: Double
    let eloMax: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                if let photoData = entry.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [.clear, PTTheme.surface.opacity(0.6)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [PTTheme.surfaceLight, PTTheme.surface],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 180)
                        .overlay {
                            Image(systemName: "mug")
                                .font(.system(size: 36))
                                .foregroundStyle(PTTheme.amber.opacity(0.25))
                        }
                }

                PTRankBadge(rank: rank)
                    .padding(10)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.name)
                            .font(.headline)
                            .foregroundStyle(PTTheme.cream)
                            .lineLimit(1)

                        if !entry.brewery.isEmpty {
                            Text(entry.brewery)
                                .font(.subheadline)
                                .foregroundStyle(PTTheme.creamDim)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    if showScore {
                        PTScoreBadge(score: entry.formattedDisplayScore(min: eloMin, max: eloMax))
                    }
                }

                HStack(spacing: 10) {
                    if !entry.style.isEmpty {
                        Text(entry.style)
                            .font(.caption)
                            .foregroundStyle(PTTheme.amber)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(PTTheme.amberDim)
                            .clipShape(Capsule())
                    }

                    if let venue = entry.venueName {
                        Label(venue, systemImage: "mappin")
                            .font(.caption)
                            .foregroundStyle(PTTheme.creamDim)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text(entry.createdAt, format: .dateTime.month(.abbreviated).day())
                        .font(.caption)
                        .foregroundStyle(PTTheme.creamDim.opacity(0.5))
                }
            }
            .padding(12)
        }
        .ptCard()
    }
}

#Preview {
    JournalView()
        .modelContainer(for: BeerEntry.self, inMemory: true)
}
