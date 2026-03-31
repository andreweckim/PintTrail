import SwiftUI
import SwiftData

struct CrawlDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var crawl: PubCrawl
    @State private var showingCheckIn = false
    @State private var showingInvite = false

    private var sortedCheckIns: [CrawlCheckIn] {
        crawl.checkIns.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        ZStack {
            PTTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Stats
                    HStack(spacing: 0) {
                        StatBubble(value: "\(crawl.beerCount)", label: "Beers")
                        StatBubble(value: "\(crawl.venueCount)", label: "Venues")
                        StatBubble(value: formatDuration(), label: "Duration")
                    }
                    .padding()
                    .ptCard()

                    // Check in button
                    Button {
                        showingCheckIn = true
                    } label: {
                        Label("Check In a Beer", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundStyle(PTTheme.stout)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(PTTheme.amber)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Stops
                    if !crawl.venues.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            PTSectionHeader(title: "Stops")
                                .padding(.leading, 4)

                            VStack(spacing: 0) {
                                ForEach(Array(crawl.venues.enumerated()), id: \.element) { index, venue in
                                    let venueCheckIns = sortedCheckIns.filter { $0.venueName == venue }
                                    HStack {
                                        Label(venue, systemImage: "mappin.circle.fill")
                                            .foregroundStyle(PTTheme.cream)
                                        Spacer()
                                        Text("\(venueCheckIns.count) beers")
                                            .font(.caption)
                                            .foregroundStyle(PTTheme.creamDim)
                                    }
                                    .padding()

                                    if index < crawl.venues.count - 1 {
                                        Divider().overlay(PTTheme.surfaceLight)
                                    }
                                }
                            }
                            .ptCard()
                        }
                    }

                    // Check-ins
                    if !sortedCheckIns.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            PTSectionHeader(title: "Check-ins")
                                .padding(.leading, 4)

                            VStack(spacing: 0) {
                                ForEach(Array(sortedCheckIns.enumerated()), id: \.element.id) { index, checkIn in
                                    CheckInRow(checkIn: checkIn)
                                        .padding()

                                    if index < sortedCheckIns.count - 1 {
                                        Divider().overlay(PTTheme.surfaceLight)
                                    }
                                }
                            }
                            .ptCard()
                        }
                    }

                    // End crawl
                    if crawl.isActive {
                        Button {
                            crawl.isActive = false
                        } label: {
                            Text("End Crawl")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(PTTheme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(crawl.name)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(PTTheme.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingInvite = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(PTTheme.amber)
                }
            }
        }
        .sheet(isPresented: $showingCheckIn) {
            CrawlCheckInView(crawl: crawl)
        }
        .sheet(isPresented: $showingInvite) {
            InviteView(crawl: crawl)
        }
    }

    private func formatDuration() -> String {
        guard let first = crawl.checkIns.min(by: { $0.timestamp < $1.timestamp })?.timestamp else {
            return "0m"
        }
        let minutes = Int(Date().timeIntervalSince(first) / 60)
        if minutes < 60 {
            return "\(minutes)m"
        }
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}

struct StatBubble: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(PTTheme.amber)
            Text(label)
                .font(.caption)
                .foregroundStyle(PTTheme.creamDim)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CheckInRow: View {
    let checkIn: CrawlCheckIn

    var body: some View {
        HStack(spacing: 12) {
            if let photoData = checkIn.photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(PTTheme.surfaceLight)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "mug")
                            .font(.caption)
                            .foregroundStyle(PTTheme.amber.opacity(0.5))
                    }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(checkIn.beerName)
                    .font(.subheadline.bold())
                    .foregroundStyle(PTTheme.cream)

                if !checkIn.brewery.isEmpty {
                    Text(checkIn.brewery)
                        .font(.caption)
                        .foregroundStyle(PTTheme.creamDim)
                }

                HStack(spacing: 4) {
                    if let venue = checkIn.venueName {
                        Text(venue)
                            .font(.caption2)
                            .foregroundStyle(PTTheme.creamDim)
                    }
                    Text(checkIn.timestamp, format: .dateTime.hour().minute())
                        .font(.caption2)
                        .foregroundStyle(PTTheme.creamDim.opacity(0.5))
                }
            }

            Spacer()
        }
    }
}
