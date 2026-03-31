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
        ZStack {
            PTTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text(crawl.name)
                            .font(.largeTitle.bold())
                            .foregroundStyle(PTTheme.cream)
                        Text(crawl.date, format: .dateTime.month(.wide).day().year())
                            .foregroundStyle(PTTheme.creamDim)
                    }
                    .padding(.top)

                    HStack(spacing: 0) {
                        StatBubble(value: "\(crawl.beerCount)", label: "Beers")
                        StatBubble(value: "\(crawl.venueCount)", label: "Venues")
                        StatBubble(value: "\(uniqueBeers)", label: "Unique")
                    }
                    .padding()
                    .ptCard()

                    if !coordinateEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            PTSectionHeader(title: "Your Route")

                            Map {
                                ForEach(Array(coordinateEntries.enumerated()), id: \.element.id) { index, checkIn in
                                    if let lat = checkIn.latitude, let lon = checkIn.longitude {
                                        Annotation("\(index + 1)", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                                            ZStack {
                                                Circle()
                                                    .fill(PTTheme.amber)
                                                    .frame(width: 28, height: 28)
                                                Text("\(index + 1)")
                                                    .font(.caption.bold())
                                                    .foregroundStyle(PTTheme.stout)
                                            }
                                        }
                                    }
                                }
                            }
                            .colorScheme(.dark)
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Timeline
                    VStack(alignment: .leading, spacing: 0) {
                        PTSectionHeader(title: "Timeline")
                            .padding(.bottom, 12)

                        ForEach(Array(sortedCheckIns.enumerated()), id: \.element.id) { index, checkIn in
                            HStack(alignment: .top, spacing: 12) {
                                VStack(spacing: 0) {
                                    Circle()
                                        .fill(PTTheme.amber)
                                        .frame(width: 10, height: 10)
                                    if index < sortedCheckIns.count - 1 {
                                        Rectangle()
                                            .fill(PTTheme.amber.opacity(0.2))
                                            .frame(width: 2)
                                            .frame(maxHeight: .infinity)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(checkIn.beerName)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(PTTheme.cream)

                                    if !checkIn.brewery.isEmpty {
                                        Text(checkIn.brewery)
                                            .font(.caption)
                                            .foregroundStyle(PTTheme.amber)
                                    }

                                    HStack {
                                        if let venue = checkIn.venueName {
                                            Label(venue, systemImage: "mappin")
                                        }
                                        Text(checkIn.timestamp, format: .dateTime.hour().minute())
                                    }
                                    .font(.caption)
                                    .foregroundStyle(PTTheme.creamDim)
                                }
                                .padding(.bottom, 16)

                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(PTTheme.background, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}
