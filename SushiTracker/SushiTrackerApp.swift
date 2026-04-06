import SwiftUI

@main
struct SushiTrackerApp: App {
    @StateObject private var auth = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
        }
    }
}
