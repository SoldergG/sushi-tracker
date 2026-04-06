import Foundation
import GoogleMobileAds
import UIKit

/// Loads and presents a single interstitial ad.
/// Create one instance per natural break point (e.g. session end).
@MainActor
final class InterstitialAdManager: NSObject, ObservableObject {
    private var interstitial: GADInterstitialAd?

    /// Pre-load the ad so it's ready when needed.
    func load() async {
        do {
            interstitial = try await GADInterstitialAd.load(
                withAdUnitID: AdConfig.interstitialAdUnitID,
                request: GADRequest()
            )
        } catch {
            // Not critical — session still ends normally without an ad.
            print("AdMob interstitial failed to load: \(error.localizedDescription)")
        }
    }

    /// Show the ad if loaded; silently does nothing if not ready.
    func show() {
        guard let ad = interstitial,
              let root = topViewController() else { return }
        ad.present(fromRootViewController: root)
        interstitial = nil
    }

    // MARK: - Private

    private func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let root = windowScene.windows.first(where: \.isKeyWindow)?.rootViewController
        else { return nil }
        var top: UIViewController = root
        while let presented = top.presentedViewController { top = presented }
        return top
    }
}
