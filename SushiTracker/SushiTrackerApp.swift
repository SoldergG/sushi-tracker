import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct SushiTrackerApp: App {
    @StateObject private var auth = AuthManager.shared

    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
        }
        .modelContainer(for: SushiRestaurant.self)
    }
}

