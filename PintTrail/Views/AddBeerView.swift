import SwiftUI
import SwiftData
import PhotosUI

struct AddBeerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \BeerEntry.eloRating, order: .reverse) private var existingEntries: [BeerEntry]

    @State private var name = ""
    @State private var brewery = ""
    @State private var style = ""
    @State private var styleSelection = ""
    @State private var customStyle = ""
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var locationManager = LocationManager()
    @State private var useLocation = true
    @State private var manualVenue = ""
    @State private var isEditingLocation = false

    @State private var rankingEngine = RankingEngine()
    @State private var pendingEntry: BeerEntry?
    @State private var rankingDone = false

    @State private var showingScanner = false
    @State private var isLookingUp = false
    @State private var lookupError: String?

    private let barcodeService = BarcodeService()

    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    // Barcode scan button
                    Section {
                        Button {
                            showingScanner = true
                        } label: {
                            Label("Scan Barcode", systemImage: "barcode.viewfinder")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                        }
                        .tint(.orange)

                        if isLookingUp {
                            HStack {
                                ProgressView()
                                    .padding(.trailing, 4)
                                Text("Looking up beer...")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if let error = lookupError {
                            Label(error, systemImage: "exclamationmark.triangle")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }

                    Section("Beer Info") {
                        TextField("Beer Name", text: $name)
                        TextField("Brewery", text: $brewery)

                        Picker("Style", selection: $styleSelection) {
                            Text("Select a style").tag("")
                            ForEach(BeerStyles.all, id: \.self) { s in
                                Text(s).tag(s)
                            }
                            Text("Custom...").tag("__custom__")
                        }
                        .onChange(of: styleSelection) { _, newValue in
                            if newValue != "__custom__" {
                                style = newValue
                                customStyle = ""
                            }
                        }

                        if styleSelection == "__custom__" {
                            TextField("Custom style", text: $customStyle)
                                .onChange(of: customStyle) { _, newValue in
                                    style = newValue
                                }
                        }
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
                            if isEditingLocation {
                                TextField("Venue name", text: $manualVenue)
                                    .onSubmit { isEditingLocation = false }
                            } else if !manualVenue.isEmpty {
                                Button {
                                    isEditingLocation = true
                                } label: {
                                    Label(manualVenue, systemImage: "mappin.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            } else if let venue = locationManager.currentVenueName {
                                Button {
                                    manualVenue = venue
                                    isEditingLocation = true
                                } label: {
                                    Label(venue, systemImage: "mappin.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            } else if locationManager.currentLocation != nil {
                                Button {
                                    isEditingLocation = true
                                } label: {
                                    Label("Tap to enter venue", systemImage: "location.fill")
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Button {
                                    isEditingLocation = true
                                } label: {
                                    Label("Enter venue name", systemImage: "location.slash")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .opacity(rankingEngine.isRanking ? 0.1 : 1.0)
                .allowsHitTesting(!rankingEngine.isRanking)

                if rankingEngine.isRanking, let pending = pendingEntry, let comparison = rankingEngine.currentComparison {
                    RankingView(
                        newEntry: pending,
                        comparisonEntry: comparison,
                        comparisonsCompleted: rankingEngine.comparisonsCompleted,
                        totalComparisons: rankingEngine.totalComparisons,
                        onChooseNew: { rankingEngine.chooseNew() },
                        onChooseExisting: { rankingEngine.chooseExisting() },
                        onSkip: { rankingEngine.skip() }
                    )
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: rankingEngine.isRanking)
            .navigationTitle("Log a Beer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(rankingEngine.isRanking)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { startSave() }
                        .disabled(name.isEmpty || rankingEngine.isRanking)
                }
            }
            .onAppear {
                locationManager.requestPermission()
            }
            .onChange(of: rankingDone) { _, done in
                if done, let entry = pendingEntry {
                    modelContext.insert(entry)
                    dismiss()
                }
            }
            .fullScreenCover(isPresented: $showingScanner) {
                ZStack(alignment: .topTrailing) {
                    BarcodeScannerView { barcode in
                        showingScanner = false
                        lookupBarcode(barcode)
                    }
                    .ignoresSafeArea()

                    Button {
                        showingScanner = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
            }
        }
    }

    private func lookupBarcode(_ barcode: String) {
        isLookingUp = true
        lookupError = nil

        Task {
            do {
                if let product = try await barcodeService.lookup(barcode: barcode) {
                    name = product.name
                    brewery = product.brand
                    style = product.style
                    if BeerStyles.all.contains(product.style) {
                        styleSelection = product.style
                    } else if !product.style.isEmpty {
                        styleSelection = "__custom__"
                        customStyle = product.style
                    }

                    // Try to load product image
                    if let imageURL = product.imageURL {
                        if let (data, _) = try? await URLSession.shared.data(from: imageURL) {
                            photoData = data
                        }
                    }
                } else {
                    lookupError = "Beer not found — enter details manually"
                }
            } catch {
                lookupError = "Lookup failed — enter details manually"
            }
            isLookingUp = false
        }
    }

    private func startSave() {
        let entry = BeerEntry(
            name: name,
            brewery: brewery,
            style: style,
            notes: notes,
            photoData: photoData,
            latitude: useLocation ? locationManager.currentLocation?.coordinate.latitude : nil,
            longitude: useLocation ? locationManager.currentLocation?.coordinate.longitude : nil,
            venueName: useLocation ? (manualVenue.isEmpty ? locationManager.currentVenueName : manualVenue) : nil
        )

        if existingEntries.isEmpty {
            modelContext.insert(entry)
            dismiss()
            return
        }

        pendingEntry = entry
        let entriesToCompare = Array(existingEntries)
        rankingEngine.startRanking(newEntry: entry, existingEntries: entriesToCompare) {
            rankingDone = true
        }
    }
}

#Preview {
    AddBeerView()
        .modelContainer(for: [BeerEntry.self, PubCrawl.self, CrawlCheckIn.self], inMemory: true)
}
