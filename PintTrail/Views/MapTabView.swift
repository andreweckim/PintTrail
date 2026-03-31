import SwiftUI
import SwiftData
import MapKit

struct MapTabView: View {
    @Query private var entries: [BeerEntry]
    @State private var position: MapCameraPosition = .automatic

    private var entriesWithLocation: [BeerEntry] {
        entries.filter { $0.latitude != nil && $0.longitude != nil }
    }

    var body: some View {
        NavigationStack {
            Group {
                if entriesWithLocation.isEmpty {
                    ContentUnavailableView(
                        "No Locations Yet",
                        systemImage: "map",
                        description: Text("Log a beer with location tagging to see it here")
                    )
                } else {
                    Map(position: $position) {
                        ForEach(entriesWithLocation) { entry in
                            if let lat = entry.latitude, let lon = entry.longitude {
                                Marker(
                                    entry.name,
                                    systemImage: "mug",
                                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                )
                                .tint(.orange)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Beer Map")
        }
    }
}

#Preview {
    MapTabView()
        .modelContainer(for: BeerEntry.self, inMemory: true)
}
