import SwiftUI

struct SushiSessionView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var isSessionActive = false
    @State private var totalPieces = 0
    @State private var sessionStart: Date? = nil
    @State private var elapsed: TimeInterval = 0
    @State private var sushiTypes = SushiTypeEntry.defaults
    @State private var currentSessionId: UUID? = nil
    @State private var showSummary = false
    @State private var summaryMessage = ""
    @StateObject private var interstitialAd = InterstitialAdManager()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var elapsedString: String {
        let m = Int(elapsed) / 60; let s = Int(elapsed) % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#1a0010"), Color(hex: "#E63946").opacity(0.8), Color(hex: "#2d0505")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Voltar")
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .glassEffect(in: Capsule())
                    }
                    Spacer()
                    Text("Sessão de Sushi")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer().frame(width: 80)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // Stats bar
                HStack {
                    VStack(spacing: 4) {
                        Text("\(totalPieces)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Peças Totais")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Text(elapsedString)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Tempo")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
                .padding(20)
                .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                .padding(.top, 8)

                if !isSessionActive {
                    Spacer()
                    VStack(spacing: 24) {
                        Text("Pronto para começar a contar as tuas peças de sushi?")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        Button { Task { await startSession() } } label: {
                            Text("🍱 Começar Sessão")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 40).padding(.vertical, 18)
                                .background(Color(hex: "#E63946"))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color(hex: "#E63946").opacity(0.5), radius: 12, y: 6)
                        }
                    }
                    Spacer()
                } else {
                    Text("● Sessão Ativa")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.top, 12)

                    ScrollView {
                        GlassEffectContainer {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach($sushiTypes) { $sushi in
                                    SushiCard(sushi: $sushi, totalPieces: $totalPieces)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 100)
                    }

                    Button { Task { await endSession() } } label: {
                        Text("🏁 Terminar Sessão")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
        .onReceive(timer) { _ in
            if isSessionActive, let start = sessionStart {
                elapsed = Date().timeIntervalSince(start)
            }
        }
        .alert("Sessão Terminada!", isPresented: $showSummary) {
            Button("OK") { dismiss() }
        } message: { Text(summaryMessage) }
    }

    private func startSession() async {
        guard let userId = auth.currentUser?.id else { return }
        await interstitialAd.load()
        do {
            sushiTypes = SushiTypeEntry.defaults; totalPieces = 0; elapsed = 0
            let session = try await SupabaseService.shared.createSession(userId: userId, sushiTypes: sushiTypes)
            currentSessionId = session.id; sessionStart = Date(); isSessionActive = true
        } catch { sessionStart = Date(); isSessionActive = true }
    }

    private func endSession() async {
        guard let start = sessionStart else { return }
        let duration = Int(Date().timeIntervalSince(start) / 60)
        let activeSushi = sushiTypes.filter { $0.pieces > 0 }
        if let id = currentSessionId {
            try? await SupabaseService.shared.updateSession(id: id, totalPieces: totalPieces, durationMinutes: duration, sushiTypes: activeSushi)
        }
        summaryMessage = "Comeste \(totalPieces) peças em \(duration) minutos!"
        isSessionActive = false; showSummary = true
        interstitialAd.show()
    }
}

// MARK: - Sushi card

private struct SushiCard: View {
    @Binding var sushi: SushiTypeEntry
    @Binding var totalPieces: Int

    var body: some View {
        VStack(spacing: 10) {
            Text(sushi.name)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
            HStack(spacing: 14) {
                Button {
                    if sushi.pieces > 0 { sushi.pieces -= 1; totalPieces -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .glassEffect(in: Circle())
                }
                Text("\(sushi.pieces)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(minWidth: 28)
                Button {
                    sushi.pieces += 1; totalPieces += 1
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .glassEffect(in: Circle())
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .glassEffect(in: RoundedRectangle(cornerRadius: 16))
    }
}
