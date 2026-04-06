import Foundation
import Supabase

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var currentUser: User? = nil
    @Published var isLoading = true

    var isAuthenticated: Bool { currentUser != nil }

    private let client = SupabaseService.shared.client

    private init() {
        Task { await start() }
    }

    private func start() async {
        // Load existing session
        if let session = try? await client.auth.session {
            currentUser = session.user
        }
        isLoading = false

        // Listen for future auth changes
        for await (_, session) in client.auth.authStateChanges {
            currentUser = session?.user
        }
    }

    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        currentUser = session.user
    }

    func signUp(email: String, password: String, name: String) async throws {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["name": .string(name)]
        )
        currentUser = response.user
    }

    func signOut() async throws {
        try await client.auth.signOut()
        currentUser = nil
    }
}
