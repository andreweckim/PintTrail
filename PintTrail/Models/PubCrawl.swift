import Foundation
import SwiftData

@Model
final class PubCrawl {
    var id: UUID
    var name: String
    var date: Date
    var isActive: Bool
    var inviteCode: String
    @Relationship(deleteRule: .cascade, inverse: \CrawlCheckIn.crawl) var checkIns: [CrawlCheckIn]

    init(name: String, date: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.isActive = true
        self.inviteCode = String(UUID().uuidString.prefix(8)).uppercased()
        self.checkIns = []
    }

    var venueCount: Int {
        Set(checkIns.compactMap(\.venueName)).count
    }

    var beerCount: Int {
        checkIns.count
    }

    var venues: [String] {
        var seen = Set<String>()
        return checkIns
            .sorted { $0.timestamp < $1.timestamp }
            .compactMap(\.venueName)
            .filter { seen.insert($0).inserted }
    }
}
