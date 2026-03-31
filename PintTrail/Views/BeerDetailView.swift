import SwiftUI
import MapKit

struct BeerDetailView: View {
    let entry: BeerEntry
    let rank: Int
    let totalEntries: Int
    let showScore: Bool
    let eloMin: Double
    let eloMax: Double

    var body: some View {
        ZStack {
            PTTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let photoData = entry.photoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.name)
                                .font(.largeTitle.bold())
                                .foregroundStyle(PTTheme.cream)

                            if !entry.brewery.isEmpty {
                                Text(entry.brewery)
                                    .font(.title3)
                                    .foregroundStyle(PTTheme.creamDim)
                            }
                        }

                        Spacer()

                        VStack(spacing: 2) {
                            if showScore {
                                PTScoreBadge(score: entry.formattedDisplayScore(min: eloMin, max: eloMax), size: .largeTitle)
                            }
                            Text("#\(rank) of \(totalEntries)")
                                .font(.caption)
                                .foregroundStyle(PTTheme.creamDim)
                        }
                    }

                    if !entry.style.isEmpty {
                        Text(entry.style)
                            .font(.subheadline)
                            .foregroundStyle(PTTheme.amber)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(PTTheme.amberDim)
                            .clipShape(Capsule())
                    }

                    if !entry.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            PTSectionHeader(title: "Notes")
                            Text(entry.notes)
                                .foregroundStyle(PTTheme.creamDim)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .ptCard()
                    }

                    if let venue = entry.venueName {
                        VStack(alignment: .leading, spacing: 6) {
                            PTSectionHeader(title: "Location")
                            Label(venue, systemImage: "mappin.circle.fill")
                                .foregroundStyle(PTTheme.creamDim)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .ptCard()
                    }

                    if let lat = entry.latitude, let lon = entry.longitude {
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                        ))) {
                            Marker(entry.venueName ?? entry.name, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                                .tint(PTTheme.amber)
                        }
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .allowsHitTesting(false)
                    }

                    Text(entry.createdAt, format: .dateTime.month(.wide).day().year().hour().minute())
                        .font(.caption)
                        .foregroundStyle(PTTheme.creamDim.opacity(0.4))
                }
                .padding()
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(PTTheme.background, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}
