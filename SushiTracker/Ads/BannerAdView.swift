import SwiftUI
import GoogleMobileAds
import UIKit

/// Adaptive banner that fills the screen width.
/// Automatically adjusts its height — typically 50–90 pt.
struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let width = UIScreen.main.bounds.width
        let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
        let banner = GADBannerView(adSize: adSize)
        banner.adUnitID = AdConfig.bannerAdUnitID
        banner.rootViewController = topViewController()
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}

    // MARK: - Height helper for SwiftUI layout

    static func adHeight() -> CGFloat {
        let width = UIScreen.main.bounds.width
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width).size.height
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
