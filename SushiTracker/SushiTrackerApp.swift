import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct SushiTrackerApp: App {
    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SushiRestaurant.self)
    }
}
