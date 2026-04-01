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

    /// Pending Elo adjustments — applied atomically at finalize.
    private var pendingNewElo: Double = 1500.0
    private var pendingNewComparisons: Int = 0
    private var pendingOpponentUpdates: [(entry: BeerEntry, elo: Double, comparisons: Int)] = []

    /// K-factor: how much a single comparison moves ratings.
    private let kFactor: Double = 32.0

    /// Minimum number of beers before showing scores.
    static let scoreThreshold = 5

    // MARK: - Elo math

    private func expectedScore(ratingA: Double, ratingB: Double) -> Double {
        1.0 / (1.0 + pow(10.0, (ratingB - ratingA) / 400.0))
    }

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
        self.pendingNewElo = newEntry.eloRating
        self.pendingNewComparisons = 0
        self.pendingOpponentUpdates = []

        guard !existingEntries.isEmpty else {
            completion()
            return
        }

        let sorted = existingEntries.sorted { $0.eloRating > $1.eloRating }
        let count = sorted.count

        if count <= 5 {
            candidates = sorted
        } else {
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
        guard candidateIndex < candidates.count else { return }
        let opponent = candidates[candidateIndex]

        let (newRating, opponentRating) = updatedRatings(winner: pendingNewElo, loser: opponent.eloRating)
        pendingNewElo = newRating
        pendingNewComparisons += 1
        pendingOpponentUpdates.append((entry: opponent, elo: opponentRating, comparisons: opponent.comparisonCount + 1))

        comparisonsCompleted += 1
        candidateIndex += 1
        presentNext()
    }

    func chooseExisting() {
        guard candidateIndex < candidates.count else { return }
        let opponent = candidates[candidateIndex]

        let (opponentRating, newRating) = updatedRatings(winner: opponent.eloRating, loser: pendingNewElo)
        pendingNewElo = newRating
        pendingNewComparisons += 1
        pendingOpponentUpdates.append((entry: opponent, elo: opponentRating, comparisons: opponent.comparisonCount + 1))

        comparisonsCompleted += 1
        candidateIndex += 1
        presentNext()
    }

    func skip() {
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
        // Apply all mutations atomically
        if let newEntry {
            newEntry.eloRating = pendingNewElo
            newEntry.comparisonCount = pendingNewComparisons
        }
        for update in pendingOpponentUpdates {
            update.entry.eloRating = update.elo
            update.entry.comparisonCount = update.comparisons
        }

        isRanking = false
        currentComparison = nil
        pendingOpponentUpdates = []
        completion?()
        completion = nil
    }
}
