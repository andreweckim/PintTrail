import SwiftUI
import SwiftData
import PhotosUI

struct CrawlCheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let crawl: PubCrawl

    @State private var beerName = ""
    @State private var brewery = ""
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            Form {
                Section("What are you drinking?") {
                    TextField("Beer Name", text: $beerName)
                    TextField("Brewery", text: $brewery)
                }

                Section("Photo") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Label("Snap a Photo", systemImage: "camera")
                        }
                    }
                    .onChange(of: selectedPhoto) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                photoData = data
                            }
                        }
                    }
                }

                Section("Notes") {
                    TextField("Quick notes...", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Location") {
                    if let venue = locationManager.currentVenueName {
                        Label(venue, systemImage: "mappin.circle.fill")
                            .foregroundStyle(.secondary)
                    } else if locationManager.currentLocation != nil {
                        Label("Location found", systemImage: "location.fill")
                            .foregroundStyle(.secondary)
                    } else {
                        Label("Getting location...", systemImage: "location.slash")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Check In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Check In") { save() }
                        .disabled(beerName.isEmpty)
                }
            }
            .onAppear {
                locationManager.requestPermission()
            }
        }
    }

    private func save() {
        let checkIn = CrawlCheckIn(
            beerName: beerName,
            brewery: brewery,
            notes: notes,
            photoData: photoData,
            latitude: locationManager.currentLocation?.coordinate.latitude,
            longitude: locationManager.currentLocation?.coordinate.longitude,
            venueName: locationManager.currentVenueName,
            crawl: crawl
        )
        modelContext.insert(checkIn)
        dismiss()
    }
}

#Preview {
    CrawlCheckInView(crawl: PubCrawl(name: "Test Crawl"))
        .modelContainer(for: [PubCrawl.self, CrawlCheckIn.self], inMemory: true)
}
