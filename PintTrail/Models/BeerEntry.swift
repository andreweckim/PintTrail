import Foundation
import SwiftData
import CoreLocation

@Model
final class BeerEntry {
    var id: UUID
    var name: String
    var brewery: String
    var style: String
    var rankPosition: Int // position in ranked list (0 = best)
    var notes: String
    var photoData: Data?
    var latitude: Double?
    var longitude: Double?
    var venueName: String?
    var createdAt: Date

    init(
        name: String,
        brewery: String = "",
        style: String = "",
        rankPosition: Int = 0,
        notes: String = "",
        photoData: Data? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        venueName: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.brewery = brewery
        self.style = style
        self.rankPosition = rankPosition
        self.notes = notes
        self.photoData = photoData
        self.latitude = latitude
        self.longitude = longitude
        self.venueName = venueName
        self.createdAt = Date()
    }

    func score(outOf total: Int) -> Double {
        guard total > 1 else { return 10.0 }
        return 10.0 - (Double(rankPosition) / Double(total - 1)) * 9.0
    }

    func formattedScore(outOf total: Int) -> String {
        String(format: "%.1f", score(outOf: total))
    }
}
