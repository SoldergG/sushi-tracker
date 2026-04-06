import Foundation

// MARK: - Sushi Types

struct SushiTypeEntry: Codable, Identifiable {
    var id: String
    var name: String
    var pieces: Int

    init(id: String = UUID().uuidString, name: String, pieces: Int = 0) {
        self.id = id
        self.name = name
        self.pieces = pieces
    }
}

// MARK: - Session

struct SushiSession: Codable, Identifiable {
    var id: UUID
    var userId: UUID
    var date: String
    var totalPieces: Int
    var durationMinutes: Int
    var sushiTypes: [SushiTypeEntry]?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case totalPieces = "total_pieces"
        case durationMinutes = "duration_minutes"
        case sushiTypes = "sushi_types"
    }
}

// MARK: - Stats

struct UserStats {
    var totalSessions: Int
    var totalPieces: Int
    var recordPieces: Int
    var averagePieces: Int
    var favoriteSushi: String
}

// MARK: - Default sushi types

extension SushiTypeEntry {
    static let defaults: [SushiTypeEntry] = [
        SushiTypeEntry(id: "1", name: "Salmão"),
        SushiTypeEntry(id: "2", name: "Atum"),
        SushiTypeEntry(id: "3", name: "Pargo"),
        SushiTypeEntry(id: "4", name: "Lula"),
        SushiTypeEntry(id: "5", name: "Camarão"),
        SushiTypeEntry(id: "6", name: "Polvo"),
        SushiTypeEntry(id: "7", name: "Robalo"),
        SushiTypeEntry(id: "8", name: "Dourada"),
        SushiTypeEntry(id: "9", name: "Enguia"),
        SushiTypeEntry(id: "10", name: "Ovas"),
    ]
}
