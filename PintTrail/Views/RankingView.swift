import SwiftUI

struct RankingView: View {
    let newEntry: BeerEntry
    let comparisonEntry: BeerEntry
    let comparisonsCompleted: Int
    let totalComparisons: Int
    let onChooseNew: () -> Void
    let onChooseExisting: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Which do you prefer?")
                .font(.title2.bold())
                .padding(.top)

            // Progress
            HStack(spacing: 4) {
                ForEach(0..<totalComparisons, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < comparisonsCompleted ? Color.orange : Color.secondary.opacity(0.3))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal)

            HStack(spacing: 16) {
                // New beer
                ComparisonCard(
                    name: newEntry.name,
                    brewery: newEntry.brewery,
                    photoData: newEntry.photoData,
                    isNew: true
                ) {
                    onChooseNew()
                }

                Text("vs")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                // Existing beer
                ComparisonCard(
                    name: comparisonEntry.name,
                    brewery: comparisonEntry.brewery,
                    photoData: comparisonEntry.photoData,
                    isNew: false
                ) {
                    onChooseExisting()
                }
            }
            .padding(.horizontal)

            Button("Too close to call — skip") {
                onSkip()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom)
        }
    }
}

struct ComparisonCard: View {
    let name: String
    let brewery: String
    let photoData: Data?
    let isNew: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                if let photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.secondary.opacity(0.15))
                        .frame(height: 140)
                        .overlay {
                            Image(systemName: "mug")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        }
                }

                Text(name)
                    .font(.subheadline.bold())
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                if !brewery.isEmpty {
                    Text(brewery)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if isNew {
                    Text("NEW")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.orange.opacity(0.2))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
