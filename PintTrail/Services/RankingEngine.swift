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

    private var rankedEntries: [BeerEntry] = []
    private var low = 0
    private var high = 0
    private var newEntry: BeerEntry?
    private var completion: ((Int) -> Void)?

    func startRanking(newEntry: BeerEntry, existingEntries: [BeerEntry], completion: @escaping (Int) -> Void) {
        self.newEntry = newEntry
        self.newBeerName = newEntry.name
        self.completion = completion

        // Sort existing by rankPosition
        self.rankedEntries = existingEntries.sorted { $0.rankPosition < $1.rankPosition }

        guard !rankedEntries.isEmpty else {
            completion(0)
            return
        }

        low = 0
        high = rankedEntries.count
        totalComparisons = max(1, Int(ceil(log2(Double(rankedEntries.count + 1)))))
        comparisonsCompleted = 0
        isRanking = true

        presentNext()
    }

    func chooseNew() {
        // New beer is better than current comparison — search higher (lower index)
        high = currentIndex
        comparisonsCompleted += 1
        presentNext()
    }

    func chooseExisting() {
        // Existing beer is better — search lower (higher index)
        low = currentIndex + 1
        comparisonsCompleted += 1
        presentNext()
    }

    func skip() {
        // Place roughly in the middle of remaining range
        let position = (low + high) / 2
        finalize(at: position)
    }

    private var currentIndex: Int {
        (low + high) / 2
    }

    private func presentNext() {
        if low >= high {
            finalize(at: low)
            return
        }

        let mid = currentIndex
        guard mid < rankedEntries.count else {
            finalize(at: rankedEntries.count)
            return
        }

        currentComparison = rankedEntries[mid]
    }

    private func finalize(at position: Int) {
        isRanking = false
        currentComparison = nil
        completion?(position)
        completion = nil
    }
}
