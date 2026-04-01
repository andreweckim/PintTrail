import Foundation
import SwiftData

enum TestData {
    static func seedIfEmpty(context: ModelContext) {
        let descriptor = FetchDescriptor<BeerEntry>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        let beers: [(name: String, brewery: String, style: String, elo: Double)] = [
            ("Pliny the Elder", "Russian River Brewing", "Double IPA", 1620),
            ("Heady Topper", "The Alchemist", "Double IPA", 1595),
            ("KBS", "Founders Brewing", "Imperial Stout", 1570),
            ("Two Hearted Ale", "Bell's Brewery", "IPA", 1545),
            ("Guinness Draught", "Guinness", "Stout", 1530),
            ("Sierra Nevada Pale Ale", "Sierra Nevada", "Pale Ale", 1510),
            ("Blue Moon", "Blue Moon Brewing", "Wheat Beer", 1485),
            ("Fat Tire", "New Belgium", "Amber Ale", 1460),
            ("Modelo Especial", "Grupo Modelo", "Lager", 1430),
            ("Bud Light", "Anheuser-Busch", "Light Lager", 1390),
        ]

        for (index, beer) in beers.enumerated() {
            let entry = BeerEntry(
                name: beer.name,
                brewery: beer.brewery,
                style: beer.style,
                eloRating: beer.elo,
                notes: ""
            )
            entry.comparisonCount = max(1, 10 - index)
            // Stagger creation dates so they're not all the same
            entry.createdAt = Date().addingTimeInterval(Double(-index) * 86400)
            context.insert(entry)
        }
    }
}
