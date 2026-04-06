import SwiftUI
import GoogleMobileAds

@main
struct SushiTrackerApp: App {
    @StateObject private var auth = AuthManager.shared

    init() {
        // Initialize Google Mobile Ads SDK on app launch.
        // Ads are only requested after this completes.
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
        }
    }
}
