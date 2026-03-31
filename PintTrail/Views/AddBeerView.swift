import SwiftUI
import SwiftData
import PhotosUI

struct AddBeerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var brewery = ""
    @State private var style = ""
    @State private var rating = 3
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var locationManager = LocationManager()
    @State private var useLocation = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Beer Info") {
                    TextField("Beer Name", text: $name)
                    TextField("Brewery", text: $brewery)
                    TextField("Style (e.g. IPA, Stout)", text: $style)
                }

                Section("Rating") {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                rating = star
                            } label: {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundStyle(star <= rating ? .yellow : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 4)
                }

                Section("Photo") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let photoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Label("Add Photo", systemImage: "camera")
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
                    TextField("Tasting notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Location") {
                    Toggle("Tag Location", isOn: $useLocation)

                    if useLocation {
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
            }
            .navigationTitle("Log a Beer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty)
                }
            }
            .onAppear {
                locationManager.requestPermission()
            }
        }
    }

    private func save() {
        let entry = BeerEntry(
            name: name,
            brewery: brewery,
            style: style,
            rating: rating,
            notes: notes,
            photoData: photoData,
            latitude: useLocation ? locationManager.currentLocation?.coordinate.latitude : nil,
            longitude: useLocation ? locationManager.currentLocation?.coordinate.longitude : nil,
            venueName: useLocation ? locationManager.currentVenueName : nil
        )
        modelContext.insert(entry)
        dismiss()
    }
}

#Preview {
    AddBeerView()
        .modelContainer(for: BeerEntry.self, inMemory: true)
}
