import SwiftUI
import MapKit

struct CrawlRecapView: View {
    let crawl: PubCrawl

    private var sortedCheckIns: [CrawlCheckIn] {
        crawl.checkIns.sorted { $0.timestamp < $1.timestamp }
    }

    private var coordinateEntries: [CrawlCheckIn] {
        sortedCheckIns.filter { $0.latitude != nil && $0.longitude != nil }
    }

    private var uniqueBeers: Int {
        Set(crawl.checkIns.map(\.beerName)).count
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
                    StatBubble(value: "\(uniqueBeers)", label: "Unique")
                }
                .padding()
                .background(.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

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

                                if !checkIn.brewery.isEmpty {
                                    Text(checkIn.brewery)
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }

                                HStack {
                                    if let venue = checkIn.venueName {
                                        Label(venue, systemImage: "mappin")
                                    }
                                    Text(checkIn.timestamp, format: .dateTime.hour().minute())
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
