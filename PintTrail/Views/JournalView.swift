import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BeerEntry.createdAt, order: .reverse) private var entries: [BeerEntry]
    @State private var showingAddEntry = false

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
                    List {
                        ForEach(entries) { entry in
                            NavigationLink(destination: BeerDetailView(entry: entry)) {
                                BeerEntryRow(entry: entry)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                }
            }
            .navigationTitle("Pint Trail")
            .toolbar {
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

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
    }
}

struct BeerEntryRow: View {
    let entry: BeerEntry

    var body: some View {
        HStack(spacing: 12) {
            if let photoData = entry.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.secondary.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "mug")
                            .foregroundStyle(.secondary)
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.headline)

                if !entry.brewery.isEmpty {
                    Text(entry.brewery)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= entry.rating ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundStyle(star <= entry.rating ? .yellow : .secondary)
                    }

                    if let venue = entry.venueName {
                        Text("  \(venue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            Text(entry.createdAt, format: .dateTime.month(.abbreviated).day())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    JournalView()
        .modelContainer(for: BeerEntry.self, inMemory: true)
}
