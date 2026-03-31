import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BeerEntry.rankPosition) private var entries: [BeerEntry]
    @State private var showingAddEntry = false
    @State private var sortByRank = true

    private var sortedEntries: [BeerEntry] {
        if sortByRank {
            return entries
        } else {
            return entries.sorted { $0.createdAt > $1.createdAt }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Beers Yet",
                        systemImage: "mug",
                        description: Text("Tap + to log your first beer")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(sortedEntries.enumerated()), id: \.element.id) { index, entry in
                                NavigationLink(destination: BeerDetailView(entry: entry, totalEntries: entries.count)) {
                                    BeerCard(entry: entry, rank: entry.rankPosition + 1, totalEntries: entries.count)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Pint Trail")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
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
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddEntry = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddBeerView()
            }
        }
    }
}

struct BeerCard: View {
    let entry: BeerEntry
    let rank: Int
    let totalEntries: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo area
            ZStack(alignment: .topLeading) {
                if let photoData = entry.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 180)
                        .overlay {
                            Image(systemName: "mug")
                                .font(.system(size: 40))
                                .foregroundStyle(.orange.opacity(0.5))
                        }
                }

                // Rank badge
                Text("#\(rank)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(10)
            }

            // Info area
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        if !entry.brewery.isEmpty {
                            Text(entry.brewery)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Score
                    Text(entry.formattedScore(outOf: totalEntries))
                        .font(.title2.bold())
                        .foregroundStyle(.orange)
                }

                HStack(spacing: 12) {
                    if !entry.style.isEmpty {
                        Text(entry.style)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.secondary.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    if let venue = entry.venueName {
                        Label(venue, systemImage: "mappin")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text(entry.createdAt, format: .dateTime.month(.abbreviated).day())
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(12)
        }
        .background(.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    JournalView()
        .modelContainer(for: BeerEntry.self, inMemory: true)
}
