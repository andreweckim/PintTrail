import SwiftUI
import MapKit

struct BeerDetailView: View {
    @Bindable var entry: BeerEntry
    let rank: Int
    let totalEntries: Int
    let showScore: Bool
    let eloMin: Double
    let eloMax: Double

    @State private var isAdjustingScore = false
    @State private var adjustedScore: Double = 5.5
    @State private var isEditingLocation = false
    @State private var editedVenue: String = ""

    private var currentScore: Double {
        entry.displayScore(min: eloMin, max: eloMax)
    }

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

                        // Tappable score
                        VStack(spacing: 2) {
                            if showScore {
                                Button {
                                    adjustedScore = round(currentScore * 2) / 2
                                    isAdjustingScore.toggle()
                                } label: {
                                    VStack(spacing: 2) {
                                        Text(entry.formattedDisplayScore(min: eloMin, max: eloMax))
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundStyle(PTTheme.amber)
                                            .shadow(color: PTTheme.amber.opacity(0.4), radius: 6)
                                        Text("tap to adjust")
                                            .font(.system(size: 9))
                                            .foregroundStyle(PTTheme.creamDim.opacity(0.5))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            Text("#\(rank) of \(totalEntries)")
                                .font(.caption)
                                .foregroundStyle(PTTheme.creamDim)
                        }
                    }

                    // Score adjustment slider
                    if isAdjustingScore {
                        VStack(spacing: 12) {
                            HStack {
                                PTSectionHeader(title: "Adjust Score")
                                Spacer()
                                Text(String(format: "%.1f", adjustedScore))
                                    .font(.title3.bold())
                                    .foregroundStyle(PTTheme.amber)
                            }

                            Slider(value: $adjustedScore, in: 1.0...10.0, step: 0.5)
                                .tint(PTTheme.amber)

                            HStack {
                                Text("1.0")
                                    .font(.caption)
                                    .foregroundStyle(PTTheme.creamDim)
                                Spacer()
                                Text("10.0")
                                    .font(.caption)
                                    .foregroundStyle(PTTheme.creamDim)
                            }

                            Button {
                                applyAdjustedScore()
                                isAdjustingScore = false
                            } label: {
                                Text("Apply")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(PTTheme.stout)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(PTTheme.amber)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding()
                        .ptCard()
                        .transition(.opacity.combined(with: .move(edge: .top)))
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

                    VStack(alignment: .leading, spacing: 6) {
                        PTSectionHeader(title: "Location")

                        if isEditingLocation {
                            HStack {
                                TextField("Venue name", text: $editedVenue)
                                    .foregroundStyle(PTTheme.cream)
                                    .onSubmit {
                                        entry.venueName = editedVenue.isEmpty ? nil : editedVenue
                                        isEditingLocation = false
                                    }
                                Button {
                                    entry.venueName = editedVenue.isEmpty ? nil : editedVenue
                                    isEditingLocation = false
                                } label: {
                                    Text("Done")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(PTTheme.amber)
                                }
                            }
                        } else if let venue = entry.venueName {
                            Button {
                                editedVenue = venue
                                isEditingLocation = true
                            } label: {
                                HStack {
                                    Label(venue, systemImage: "mappin.circle.fill")
                                        .foregroundStyle(PTTheme.creamDim)
                                    Spacer()
                                    Image(systemName: "pencil")
                                        .font(.caption)
                                        .foregroundStyle(PTTheme.creamDim.opacity(0.5))
                                }
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button {
                                editedVenue = ""
                                isEditingLocation = true
                            } label: {
                                Label("Add location", systemImage: "plus.circle")
                                    .foregroundStyle(PTTheme.creamDim.opacity(0.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .ptCard()

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
        .animation(.easeInOut(duration: 0.2), value: isAdjustingScore)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(PTTheme.background, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func applyAdjustedScore() {
        // Convert the desired 1-10 score back to an Elo rating
        guard eloMax > eloMin else { return }
        let normalized = (adjustedScore - 1.0) / 9.0 // 0.0 to 1.0
        entry.eloRating = eloMin + normalized * (eloMax - eloMin)
    }
}
