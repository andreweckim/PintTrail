import SwiftUI
import MapKit

struct CrawlRecapView: View {
    let crawl: PubCrawl

    private var sortedCheckIns: [CrawlCheckIn] {
        crawl.checkIns.sorted { $0.timestamp < $1.timestamp }
    }

    private var averageRating: Double {
        guard !crawl.checkIns.isEmpty else { return 0 }
        return Double(crawl.checkIns.map(\.rating).reduce(0, +)) / Double(crawl.checkIns.count)
    }

    private var topBeer: CrawlCheckIn? {
        crawl.checkIns.max(by: { $0.rating < $1.rating })
    }

    private var coordinateEntries: [CrawlCheckIn] {
        sortedCheckIns.filter { $0.latitude != nil && $0.longitude != nil }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(crawl.name)
                        .font(.largeTitle.bold())
                    Text(crawl.date, format: .dateTime.month(.wide).day().year())
                        .foregroundStyle(.secondary)
                }
                .padding(.top)

                // Stats
                HStack(spacing: 0) {
                    StatBubble(value: "\(crawl.beerCount)", label: "Beers")
                    StatBubble(value: "\(crawl.venueCount)", label: "Venues")
                    StatBubble(value: String(format: "%.1f", averageRating), label: "Avg Rating")
                }
                .padding()
                .background(.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Top beer
                if let top = topBeer {
                    VStack(spacing: 4) {
                        Text("Top Beer")
                            .font(.headline)
                        Text(top.beerName)
                            .font(.title3.bold())
                            .foregroundStyle(.orange)
                        if !top.brewery.isEmpty {
                            Text(top.brewery)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= top.rating ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundStyle(star <= top.rating ? .yellow : .secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Route map
                if !coordinateEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Route")
                            .font(.headline)

                        Map {
                            ForEach(Array(coordinateEntries.enumerated()), id: \.element.id) { index, checkIn in
                                if let lat = checkIn.latitude, let lon = checkIn.longitude {
                                    Annotation("\(index + 1)", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                                        ZStack {
                                            Circle()
                                                .fill(.orange)
                                                .frame(width: 28, height: 28)
                                            Text("\(index + 1)")
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                // Timeline
                VStack(alignment: .leading, spacing: 0) {
                    Text("Timeline")
                        .font(.headline)
                        .padding(.bottom, 12)

                    ForEach(Array(sortedCheckIns.enumerated()), id: \.element.id) { index, checkIn in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(.orange)
                                    .frame(width: 10, height: 10)
                                if index < sortedCheckIns.count - 1 {
                                    Rectangle()
                                        .fill(.orange.opacity(0.3))
                                        .frame(width: 2)
                                        .frame(maxHeight: .infinity)
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(checkIn.beerName)
                                    .font(.subheadline.bold())
                                HStack {
                                    if let venue = checkIn.venueName {
                                        Text(venue)
                                    }
                                    Text(checkIn.timestamp, format: .dateTime.hour().minute())
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)

                                HStack(spacing: 1) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= checkIn.rating ? "star.fill" : "star")
                                            .font(.system(size: 8))
                                            .foregroundStyle(star <= checkIn.rating ? .yellow : .secondary)
                                    }
                                }
                            }
                            .padding(.bottom, 16)

                            Spacer()
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
