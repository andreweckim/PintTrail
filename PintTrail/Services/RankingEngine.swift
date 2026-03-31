import Foundation
import SwiftData

@MainActor
@Observable
final class RankingEngine {
    var isRanking = false
    var currentComparison: BeerEntry?
    var newBeerName: String = ""
    var comparisonsCompleted = 0
    var totalComparisons = 0

    private var candidates: [BeerEntry] = []
    private var candidateIndex = 0
    private var newEntry: BeerEntry?
    private var completion: (() -> Void)?

    /// K-factor: how much a single comparison moves ratings.
    /// Higher = ratings shift faster (good for small datasets).
    private let kFactor: Double = 32.0

    /// Minimum number of beers before showing scores (show rank only before this).
    static let scoreThreshold = 5

    // MARK: - Elo math

    /// Expected score (probability of winning) for ratingA vs ratingB.
    private func expectedScore(ratingA: Double, ratingB: Double) -> Double {
        1.0 / (1.0 + pow(10.0, (ratingB - ratingA) / 400.0))
    }

    /// Update both ratings after a comparison. Returns (newRatingA, newRatingB).
    private func updatedRatings(winner: Double, loser: Double) -> (Double, Double) {
        let expectedWin = expectedScore(ratingA: winner, ratingB: loser)
        let expectedLose = 1.0 - expectedWin

        let newWinner = winner + kFactor * (1.0 - expectedWin)
        let newLoser = loser + kFactor * (0.0 - expectedLose)

        return (newWinner, newLoser)
    }

    // MARK: - Ranking flow

    func startRanking(newEntry: BeerEntry, existingEntries: [BeerEntry], completion: @escaping () -> Void) {
        self.newEntry = newEntry
        self.newBeerName = newEntry.name
        self.completion = completion

        guard !existingEntries.isEmpty else {
            completion()
            return
        }

        // Pick comparison candidates: use binary search-style selection.
        // Sort by Elo, then pick log2(n) spread across the range.
        let sorted = existingEntries.sorted { $0.eloRating > $1.eloRating }
        let count = sorted.count

        if count <= 5 {
            candidates = sorted
        } else {
            // Pick ~log2(n)+1 evenly spaced candidates
            let numComparisons = min(count, Int(ceil(log2(Double(count)))) + 1)
            var picked: [BeerEntry] = []
            for i in 0..<numComparisons {
                let index = i * (count - 1) / (numComparisons - 1)
                picked.append(sorted[index])
            }
            candidates = picked
        }

        totalComparisons = candidates.count
        comparisonsCompleted = 0
        candidateIndex = 0
        isRanking = true

        presentNext()
    }

    func chooseNew() {
        guard let newEntry, candidateIndex < candidates.count else { return }
        let opponent = candidates[candidateIndex]

        // New beer wins
        let (newRating, opponentRating) = updatedRatings(winner: newEntry.eloRating, loser: opponent.eloRating)
        newEntry.eloRating = newRating
        opponent.eloRating = opponentRating
        newEntry.comparisonCount += 1
        opponent.comparisonCount += 1

        comparisonsCompleted += 1
        candidateIndex += 1
        presentNext()
    }

    func chooseExisting() {
        guard let newEntry, candidateIndex < candidates.count else { return }
        let opponent = candidates[candidateIndex]

        // Existing beer wins
        let (opponentRating, newRating) = updatedRatings(winner: opponent.eloRating, loser: newEntry.eloRating)
        newEntry.eloRating = newRating
        opponent.eloRating = opponentRating
        newEntry.comparisonCount += 1
        opponent.comparisonCount += 1

        comparisonsCompleted += 1
        candidateIndex += 1
        presentNext()
    }

    func skip() {
        // No rating change, move to next
        comparisonsCompleted += 1
        candidateIndex += 1
        presentNext()
    }

    private func presentNext() {
        if candidateIndex >= candidates.count {
            finalize()
            return
        }
        currentComparison = candidates[candidateIndex]
    }

    private func finalize() {
        isRanking = false
        currentComparison = nil
        completion?()
        completion = nil
    }
}
