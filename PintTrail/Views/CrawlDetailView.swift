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
        List {
            Section {
                HStack(spacing: 20) {
                    StatBubble(value: "\(crawl.beerCount)", label: "Beers")
                    StatBubble(value: "\(crawl.venueCount)", label: "Venues")
                    StatBubble(value: formatDuration(), label: "Duration")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            Section {
                Button {
                    showingCheckIn = true
                } label: {
                    Label("Check In a Beer", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .tint(.orange)
            }

            if !crawl.venues.isEmpty {
                Section("Stops") {
                    ForEach(crawl.venues, id: \.self) { venue in
                        let venueCheckIns = sortedCheckIns.filter { $0.venueName == venue }
                        HStack {
                            Label(venue, systemImage: "mappin.circle.fill")
                            Spacer()
                            Text("\(venueCheckIns.count) beers")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if !sortedCheckIns.isEmpty {
                Section("Check-ins") {
                    ForEach(sortedCheckIns) { checkIn in
                        CheckInRow(checkIn: checkIn)
                    }
                    .onDelete(perform: deleteCheckIns)
                }
            }

            Section {
                Button("End Crawl", role: .destructive) {
                    crawl.isActive = false
                }
            }
        }
        .navigationTitle(crawl.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingInvite = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
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

    private func deleteCheckIns(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedCheckIns[index])
        }
    }
}

struct StatBubble: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.orange)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
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
                    .fill(.secondary.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "mug")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(checkIn.beerName)
                    .font(.subheadline.bold())

                if !checkIn.brewery.isEmpty {
                    Text(checkIn.brewery)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 4) {
                    if let venue = checkIn.venueName {
                        Text(venue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Text(checkIn.timestamp, format: .dateTime.hour().minute())
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            HStack(spacing: 1) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= checkIn.rating ? "star.fill" : "star")
                        .font(.system(size: 8))
                        .foregroundStyle(star <= checkIn.rating ? .yellow : .secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
