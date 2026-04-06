import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.url)!,
            supabaseKey: SupabaseConfig.anonKey
        )
    }

    // MARK: - Sessions

    func createSession(userId: UUID, sushiTypes: [SushiTypeEntry]) async throws -> SushiSession {
        struct Insert: Encodable {
            let user_id: UUID
            let date: String
            let total_pieces: Int
            let duration_minutes: Int
            let sushi_types: [SushiTypeEntry]
        }

        let insert = Insert(
            user_id: userId,
            date: ISO8601DateFormatter().string(from: Date()),
            total_pieces: 0,
            duration_minutes: 0,
            sushi_types: sushiTypes
        )

        return try await client
            .from("sushi_sessions")
            .insert(insert)
            .select()
            .single()
            .execute()
            .value
    }

    func updateSession(id: UUID, totalPieces: Int, durationMinutes: Int, sushiTypes: [SushiTypeEntry]) async throws {
        struct Update: Encodable {
            let total_pieces: Int
            let duration_minutes: Int
            let sushi_types: [SushiTypeEntry]
        }

        try await client
            .from("sushi_sessions")
            .update(Update(total_pieces: totalPieces, duration_minutes: durationMinutes, sushi_types: sushiTypes))
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Stats

    func getUserStats(userId: UUID) async throws -> UserStats {
        struct Row: Decodable {
            let total_pieces: Int
        }

        let rows: [Row] = try await client
            .from("sushi_sessions")
            .select("total_pieces")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value

        let total = rows.reduce(0) { $0 + $1.total_pieces }
        let record = rows.map(\.total_pieces).max() ?? 0
        let avg = rows.isEmpty ? 0 : total / rows.count

        return UserStats(
            totalSessions: rows.count,
            totalPieces: total,
            recordPieces: record,
            averagePieces: avg,
            favoriteSushi: "Salmão"
        )
    }
}
