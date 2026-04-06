import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var restaurants: [SushiRestaurant]
    private let bannerHeight = BannerAdView.adHeight()

    private var totalPieces: Int {
        restaurants.reduce(0) { $0 + $1.totalPiecesEaten }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "#ff6b6b"), Color(hex: "#E63946"), Color(hex: "#c0392b")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Logo & title
                    VStack(spacing: 8) {
                        Text("🍣")
                            .font(.system(size: 64))
                        Text("Sushi Tracker")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                        Text("O teu contador de sushi")
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .padding(.top, 20)

                    // Stats
                    GlassEffectContainer {
                        HStack(spacing: 10) {
                            StatCard(number: "\(restaurants.count)", label: "Restaurantes")
                            StatCard(number: "\(totalPieces)", label: "Peças Totais")
                        }
                    }

                    // KeepAwake (único extra não no tab bar)
                    NavigationLink { KeepAwakeView() } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("⚡ Modo Contínuo")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("Tela nunca se apaga")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .padding(.horizontal, 18).padding(.vertical, 14)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    }

                    Spacer().frame(height: bannerHeight + 16)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)

            // Banner apenas no ecrã inicial (menos invasivo)
            VStack(spacing: 0) {
                Divider().opacity(0.3)
                BannerAdView()
                    .frame(height: bannerHeight)
                    .background(.ultraThinMaterial)
            }
        }
    }
}

private struct StatCard: View {
    let number: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(number)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
    }
}
