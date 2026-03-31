import SwiftUI
import SwiftData

struct CrawlsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PubCrawl.date, order: .reverse) private var crawls: [PubCrawl]
    @State private var showingCreateCrawl = false

    private var activeCrawls: [PubCrawl] {
        crawls.filter(\.isActive)
    }

    private var pastCrawls: [PubCrawl] {
        crawls.filter { !$0.isActive }
    }

    var body: some View {
        NavigationStack {
            Group {
                if crawls.isEmpty {
                    ContentUnavailableView(
                        "No Crawls Yet",
                        systemImage: "figure.walk",
                        description: Text("Start a pub crawl and track your beers along the way")
                    )
                } else {
                    List {
                        if !activeCrawls.isEmpty {
                            Section("Active") {
                                ForEach(activeCrawls) { crawl in
                                    NavigationLink(destination: CrawlDetailView(crawl: crawl)) {
                                        CrawlRow(crawl: crawl)
                                    }
                                }
                            }
                        }

                        if !pastCrawls.isEmpty {
                            Section("Past Crawls") {
                                ForEach(pastCrawls) { crawl in
                                    NavigationLink(destination: CrawlRecapView(crawl: crawl)) {
                                        CrawlRow(crawl: crawl)
                                    }
                                }
                                .onDelete(perform: deletePastCrawls)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Crawls")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingCreateCrawl = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateCrawl) {
                CreateCrawlView()
            }
        }
    }

    private func deletePastCrawls(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(pastCrawls[index])
        }
    }
}

struct CrawlRow: View {
    let crawl: PubCrawl

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(crawl.name)
                        .font(.headline)
                    if crawl.isActive {
                        Text("LIVE")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.green)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }

                Text(crawl.date, format: .dateTime.month(.abbreviated).day().year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label("\(crawl.beerCount)", systemImage: "mug")
                    Label("\(crawl.venueCount)", systemImage: "mappin")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CrawlsView()
        .modelContainer(for: [PubCrawl.self, CrawlCheckIn.self], inMemory: true)
}
