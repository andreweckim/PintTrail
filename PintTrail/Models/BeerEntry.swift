import Foundation
import SwiftData
import CoreLocation

@Model
final class BeerEntry {
    var id: UUID
    var name: String
    var brewery: String
    var style: String
    var rating: Int // 1-5
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
        rating: Int = 3,
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
        self.rating = rating
        self.notes = notes
        self.photoData = photoData
        self.latitude = latitude
        self.longitude = longitude
        self.venueName = venueName
        self.createdAt = Date()
    }
}
