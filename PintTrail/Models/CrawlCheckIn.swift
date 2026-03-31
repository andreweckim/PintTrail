import Foundation
import SwiftData

@Model
final class CrawlCheckIn {
    var id: UUID
    var beerName: String
    var brewery: String
    var notes: String
    var photoData: Data?
    var latitude: Double?
    var longitude: Double?
    var venueName: String?
    var timestamp: Date
    var crawl: PubCrawl?

    init(
        beerName: String,
        brewery: String = "",
        notes: String = "",
        photoData: Data? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        venueName: String? = nil,
        crawl: PubCrawl? = nil
    ) {
        self.id = UUID()
        self.beerName = beerName
        self.brewery = brewery
        self.notes = notes
        self.photoData = photoData
        self.latitude = latitude
        self.longitude = longitude
        self.venueName = venueName
        self.timestamp = Date()
        self.crawl = crawl
    }
}
