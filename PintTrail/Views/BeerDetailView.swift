import SwiftUI
import MapKit

struct BeerDetailView: View {
    let entry: BeerEntry

    var body: some View {
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

                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.name)
                        .font(.largeTitle.bold())

                    if !entry.brewery.isEmpty {
                        Text(entry.brewery)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    if !entry.style.isEmpty {
                        Text(entry.style)
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.secondary.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= entry.rating ? "star.fill" : "star")
                                .font(.title3)
                                .foregroundStyle(star <= entry.rating ? .yellow : .secondary)
                        }
                    }
                    .padding(.top, 4)
                }

                if !entry.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.headline)
                        Text(entry.notes)
                            .foregroundStyle(.secondary)
                    }
                }

                if let venue = entry.venueName {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location")
                            .font(.headline)
                        Label(venue, systemImage: "mappin.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }

                if let lat = entry.latitude, let lon = entry.longitude {
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    ))) {
                        Marker(entry.venueName ?? entry.name, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .allowsHitTesting(false)
                }

                Text(entry.createdAt, format: .dateTime.month(.wide).day().year().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
