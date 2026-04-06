import SwiftUI

struct HomeView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var stats: UserStats? = nil
    @State private var isLoadingStats = true

    private var userName: String {
        // Supabase user_metadata stores the name
        // auth.currentUser?.userMetadata["name"] if decoded properly
        auth.currentUser?.email?.components(separatedBy: "@").first?.capitalized ?? "Utilizador"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                ZStack(alignment: .bottomLeading) {
                    Color(hex: "#E63946")
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Bem-vindo(a),")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.9))
                        Text(userName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                    .padding(.top, 20)
                }
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, -16)

                // Stats
                if let s = stats {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("📊 As Tuas Estatísticas")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "#333333"))

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(number: "\(s.totalSessions)", label: "Sessões")
                            StatCard(number: "\(s.totalPieces)", label: "Total Peças")
                            StatCard(number: "\(s.recordPieces)", label: "Recorde")
                            StatCard(number: "\(s.averagePieces)", label: "Média")
                        }

                        HStack {
                            Text("🍣 Favorito:")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#333333"))
                            Spacer()
                            Text(s.favoriteSushi)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "#E63946"))
                        }
                        .padding(16)
                        .background(Color(hex: "#f8f9fa"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.07), radius: 8, y: 2)
                    .padding(.horizontal, 4)
                    .padding(.top, 20)
                } else if isLoadingStats {
                    ProgressView()
                        .padding(.top, 30)
                }

                // Actions
                VStack(alignment: .leading, spacing: 14) {
                    Text("🎯 Ações Rápidas")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "#333333"))
                        .padding(.horizontal, 4)

                    NavigationLink { SushiSessionView() } label: {
                        ActionButton(title: "🍱 Nova Sessão", subtitle: "Começa a contar peças")
                    }
                    NavigationLink { KeepAwakeView() } label: {
                        ActionButton(title: "⚡ Modo Contínuo", subtitle: "Tela nunca se apaga", accentColor: Color(hex: "#FFB700"))
                    }
                    NavigationLink { SushiListView() } label: {
                        ActionButton(title: "📝 Lista de Sushi", subtitle: "Gerir tipos de sushi")
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 4)

                // Sign out
                Button {
                    Task { try? await auth.signOut() }
                } label: {
                    Text("Sair")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "#dc3545"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 24)
                .padding(.horizontal, 4)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .background(Color(hex: "#f8f9fa"))
        .navigationBarHidden(true)
        .task { await loadStats() }
    }

    private func loadStats() async {
        guard let userId = auth.currentUser?.id else { return }
        do {
            stats = try await SupabaseService.shared.getUserStats(userId: userId)
        } catch {
            // Show empty stats on error
            stats = UserStats(totalSessions: 0, totalPieces: 0, recordPieces: 0, averagePieces: 0, favoriteSushi: "—")
        }
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
                .foregroundColor(Color(hex: "#E63946"))
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#666666"))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(hex: "#f8f9fa"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct ActionButton: View {
    let title: String
    let subtitle: String
    var accentColor: Color = .white

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#333333"))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#666666"))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "#999999"))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.07), radius: 6, y: 2)
    }
}
