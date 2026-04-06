import Foundation
import SwiftData
import CoreLocation

@Model
final class SushiRestaurant {
    var id: UUID
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var rating: Int          // 1–5 stars
    var notes: String
    var visitedAt: Date
    var totalPiecesEaten: Int

    init(
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        rating: Int = 0,
        notes: String = "",
        visitedAt: Date = Date(),
        totalPiecesEaten: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.notes = notes
        self.visitedAt = visitedAt
        self.totalPiecesEaten = totalPiecesEaten
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
