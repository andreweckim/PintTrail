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
            ZStack {
                PTTheme.background.ignoresSafeArea()

                if crawls.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 48))
                            .foregroundStyle(PTTheme.amber.opacity(0.4))
                        Text("No Crawls Yet")
                            .font(.title2.bold())
                            .foregroundStyle(PTTheme.cream)
                        Text("Start a pub crawl and track your beers along the way")
                            .font(.subheadline)
                            .foregroundStyle(PTTheme.creamDim)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            if !activeCrawls.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    PTSectionHeader(title: "Active")
                                        .padding(.leading, 4)
                                    ForEach(activeCrawls) { crawl in
                                        NavigationLink(destination: CrawlDetailView(crawl: crawl)) {
                                            CrawlCard(crawl: crawl)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            if !pastCrawls.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    PTSectionHeader(title: "Past Crawls")
                                        .padding(.leading, 4)
                                    ForEach(pastCrawls) { crawl in
                                        NavigationLink(destination: CrawlRecapView(crawl: crawl)) {
                                            CrawlCard(crawl: crawl)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Crawls")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(PTTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingCreateCrawl = true }) {
                        Image(systemName: "plus")
                            .foregroundStyle(PTTheme.amber)
                    }
                }
            }
            .sheet(isPresented: $showingCreateCrawl) {
                CreateCrawlView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct CrawlCard: View {
    let crawl: PubCrawl

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(crawl.name)
                    .font(.headline)
                    .foregroundStyle(PTTheme.cream)

                if crawl.isActive {
                    Text("LIVE")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(PTTheme.amber)
                        .foregroundStyle(PTTheme.stout)
                        .clipShape(Capsule())
                }

                Spacer()

                Text(crawl.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(PTTheme.creamDim)
            }

            HStack(spacing: 16) {
                Label("\(crawl.beerCount) beers", systemImage: "mug")
                Label("\(crawl.venueCount) stops", systemImage: "mappin")
            }
            .font(.caption)
            .foregroundStyle(PTTheme.creamDim)
        }
        .padding()
        .ptCard()
    }
}

#Preview {
    CrawlsView()
        .modelContainer(for: [PubCrawl.self, CrawlCheckIn.self], inMemory: true)
}
