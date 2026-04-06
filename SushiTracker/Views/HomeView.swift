import SwiftUI

struct HomeView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var stats: UserStats? = nil
    @State private var isLoadingStats = true
    private let bannerHeight = BannerAdView.adHeight()

    private var userName: String {
        auth.currentUser?.email?.components(separatedBy: "@").first?.capitalized ?? "Utilizador"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Gradient background makes glass cards pop
            LinearGradient(
                colors: [Color(hex: "#ff6b6b"), Color(hex: "#E63946"), Color(hex: "#c0392b")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header greeting
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bem-vindo(a),")
                            .font(.system(size: 17))
                            .foregroundStyle(.white.opacity(0.85))
                        Text(userName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.top, 8)

                    // Stats
                    if let s = stats {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("📊 As Tuas Estatísticas")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)

                            GlassEffectContainer {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    StatCard(number: "\(s.totalSessions)", label: "Sessões")
                                    StatCard(number: "\(s.totalPieces)", label: "Total Peças")
                                    StatCard(number: "\(s.recordPieces)", label: "Recorde")
                                    StatCard(number: "\(s.averagePieces)", label: "Média")
                                }
                            }

                            HStack {
                                Text("🍣 Favorito:")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.white.opacity(0.9))
                                Spacer()
                                Text(s.favoriteSushi)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .padding(16)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                        }
                    } else if isLoadingStats {
                        ProgressView().tint(.white).padding(.top, 20)
                    }

                    // Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🎯 Ações Rápidas")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)

                        GlassEffectContainer {
                            VStack(spacing: 10) {
                                NavigationLink { SushiSessionView() } label: {
                                    ActionRow(title: "🍱 Nova Sessão", subtitle: "Começa a contar peças")
                                }
                                NavigationLink { KeepAwakeView() } label: {
                                    ActionRow(title: "⚡ Modo Contínuo", subtitle: "Tela nunca se apaga")
                                }
                                NavigationLink { SushiListView() } label: {
                                    ActionRow(title: "📝 Lista de Sushi", subtitle: "Gerir tipos de sushi")
                                }
                            }
                        }
                    }

                    // Sign out
                    Button {
                        Task { try? await auth.signOut() }
                    } label: {
                        Text("Sair")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.bottom, bannerHeight + 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationBarHidden(true)
            .task { await loadStats() }

            // Sticky banner
            VStack(spacing: 0) {
                Divider().opacity(0.3)
                BannerAdView()
                    .frame(height: bannerHeight)
                    .background(.ultraThinMaterial)
            }
        }
    }

    private func loadStats() async {
        guard let userId = auth.currentUser?.id else { return }
        do { stats = try await SupabaseService.shared.getUserStats(userId: userId) }
        catch { stats = UserStats(totalSessions: 0, totalPieces: 0, recordPieces: 0, averagePieces: 0, favoriteSushi: "—") }
        isLoadingStats = false
    }
}

// MARK: - Sub-components

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

private struct ActionRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
    }
}
