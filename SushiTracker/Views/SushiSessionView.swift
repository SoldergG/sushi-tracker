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
        let m = Int(elapsed) / 60
        let s = Int(elapsed) % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Voltar")
                    }
                    .foregroundColor(.white)
                }
                Spacer()
                Text("Sessão de Sushi")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer().frame(width: 70)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(hex: "#E63946"))

            // Stats bar
            HStack {
                VStack {
                    Text("\(totalPieces)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "#E63946"))
                    Text("Peças Totais")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#666666"))
                }
                Spacer()
                VStack {
                    Text(elapsedString)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "#E63946"))
                    Text("Tempo")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#666666"))
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.07), radius: 6, y: 2)
            .padding(16)

            if !isSessionActive {
                // Start screen
                Spacer()
                VStack(spacing: 24) {
                    Text("Pronto para começar a contar as tuas peças de sushi?")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#333333"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    Button {
                        Task { await startSession() }
                    } label: {
                        Text("🍱 Começar Sessão")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 18)
                            .background(Color(hex: "#E63946"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                Spacer()
            } else {
                // Active session
                Text("● Sessão Ativa")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#28a745"))
                    .padding(.top, 4)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach($sushiTypes) { $sushi in
                            SushiCard(sushi: $sushi, totalPieces: $totalPieces)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 100)
                }

                Button {
                    Task { await endSession() }
                } label: {
                    Text("🏁 Terminar Sessão")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#dc3545"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(16)
            }
        }
        .background(Color(hex: "#f8f9fa"))
        .navigationBarHidden(true)
        .onReceive(timer) { _ in
            if isSessionActive, let start = sessionStart {
                elapsed = Date().timeIntervalSince(start)
            }
        }
        .alert("Sessão Terminada!", isPresented: $showSummary) {
            Button("OK") { dismiss() }
        } message: {
            Text(summaryMessage)
        }
    }

    private func startSession() async {
        guard let userId = auth.currentUser?.id else { return }
        // Pre-load the interstitial so it's ready when the session ends
        await interstitialAd.load()
        do {
            sushiTypes = SushiTypeEntry.defaults
            totalPieces = 0
            elapsed = 0
            let session = try await SupabaseService.shared.createSession(
                userId: userId,
                sushiTypes: sushiTypes
            )
            currentSessionId = session.id
            sessionStart = Date()
            isSessionActive = true
        } catch {
            // fallback: start session without DB (local only)
            sessionStart = Date()
            isSessionActive = true
        }
    }

    private func endSession() async {
        guard let start = sessionStart else { return }
        let duration = Int(Date().timeIntervalSince(start) / 60)
        let activeSushi = sushiTypes.filter { $0.pieces > 0 }

        if let id = currentSessionId {
            try? await SupabaseService.shared.updateSession(
                id: id,
                totalPieces: totalPieces,
                durationMinutes: duration,
                sushiTypes: activeSushi
            )
        }

        summaryMessage = "Comeste \(totalPieces) peças em \(duration) minutos!"
        isSessionActive = false
        showSummary = true

        // Show interstitial after session ends — natural break point
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
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "#333333"))
            HStack(spacing: 12) {
                Button {
                    if sushi.pieces > 0 { sushi.pieces -= 1; totalPieces -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color(hex: "#dc3545"))
                        .clipShape(Circle())
                }

                Text("\(sushi.pieces)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#333333"))
                    .frame(minWidth: 28)

                Button {
                    sushi.pieces += 1; totalPieces += 1
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color(hex: "#28a745"))
                        .clipShape(Circle())
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 1)
    }
}
