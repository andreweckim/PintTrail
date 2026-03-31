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
            ZStack {
                PTTheme.background.ignoresSafeArea()

                if entriesWithLocation.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "map")
                            .font(.system(size: 48))
                            .foregroundStyle(PTTheme.amber.opacity(0.4))
                        Text("No Locations Yet")
                            .font(.title2.bold())
                            .foregroundStyle(PTTheme.cream)
                        Text("Log a beer with location tagging to see it here")
                            .font(.subheadline)
                            .foregroundStyle(PTTheme.creamDim)
                    }
                } else {
                    Map(position: $position) {
                        ForEach(entriesWithLocation) { entry in
                            if let lat = entry.latitude, let lon = entry.longitude {
                                Marker(
                                    entry.name,
                                    systemImage: "mug",
                                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                )
                                .tint(PTTheme.amber)
                            }
                        }
                    }
                    .colorScheme(.dark)
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MapTabView()
        .modelContainer(for: BeerEntry.self, inMemory: true)
}
