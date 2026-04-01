import Foundation
import SwiftData
import CoreLocation

@Model
final class BeerEntry {
    var id: UUID
    var name: String
    var brewery: String
    var style: String
    var eloRating: Double
    var comparisonCount: Int
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
        eloRating: Double = 1500.0,
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
        self.eloRating = eloRating
        self.comparisonCount = 0
        self.notes = notes
        self.photoData = photoData
        self.latitude = latitude
        self.longitude = longitude
        self.venueName = venueName
        self.createdAt = Date()
    }

    /// Convert Elo to a 1.0–10.0 display score based on where this beer
    /// sits within the full range of the user's ratings.
    func displayScore(min: Double, max: Double) -> Double {
        guard max > min else { return 5.5 }
        let normalized = (eloRating - min) / (max - min) // 0.0 to 1.0
        return 1.0 + normalized * 9.0 // 1.0 to 10.0
    }

    func formattedDisplayScore(min: Double, max: Double) -> String {
        String(format: "%.1f", displayScore(min: min, max: max))
    }
}
