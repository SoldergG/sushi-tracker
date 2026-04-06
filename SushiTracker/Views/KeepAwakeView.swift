import SwiftUI
import UIKit

struct KeepAwakeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var totalPieces = 0
    @State private var isKeepAwakeActive = true
    @State private var showResetAlert = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#1a1000"), Color(hex: "#FFB700").opacity(0.6), Color(hex: "#2d1e00")],
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
                    Text("Modo Contínuo")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer().frame(width: 80)
                }
                .padding(.horizontal, 20).padding(.vertical, 16)

                ScrollView {
                    VStack(spacing: 20) {
                        // Status card
                        VStack(spacing: 6) {
                            Text(isKeepAwakeActive ? "⚡ Tela Ativa" : "😴 Tela Normal")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                            Text("A tela permanecerá ativa enquanto o modo estiver ativo")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.75))
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 18))

                        // Counter
                        VStack(spacing: 8) {
                            Text("Peças de Sushi")
                                .font(.system(size: 18))
                                .foregroundStyle(.white.opacity(0.85))
                            Text("\(totalPieces)")
                                .font(.system(size: 88, weight: .bold))
                                .foregroundStyle(.white)
                            Text("toque para adicionar")
                                .font(.system(size: 14)).italic()
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        .padding(.vertical, 10)

                        // +1 button
                        Button { totalPieces += 1 } label: {
                            Text("+1 Peça")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 22)
                                .background(Color(hex: "#E63946"))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: Color(hex: "#E63946").opacity(0.4), radius: 14, y: 7)
                        }

                        // Reset + Toggle
                        GlassEffectContainer {
                            HStack(spacing: 12) {
                                Button { showResetAlert = true } label: {
                                    Text("🔄 Reiniciar")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                                }
                                Button {
                                    isKeepAwakeActive.toggle()
                                    UIApplication.shared.isIdleTimerDisabled = isKeepAwakeActive
                                } label: {
                                    Text(isKeepAwakeActive ? "⏸ Pausar" : "▶ Ativar")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                                }
                            }
                        }

                        // Instructions
                        VStack(alignment: .leading, spacing: 10) {
                            Text("📋 Instruções")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.white)
                            ForEach([
                                "Toque em \"+1 Peça\" para adicionar uma peça",
                                "A tela permanecerá ativa para facilitar a contagem",
                                "Use \"Reiniciar\" para zerar o contador",
                                "\"Pausar\" permite que o dispositivo desligue normalmente",
                            ], id: \.self) { tip in
                                Text("• \(tip)")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .alert("Reiniciar Contador", isPresented: $showResetAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Reiniciar", role: .destructive) { totalPieces = 0 }
        } message: { Text("Tem certeza que deseja reiniciar o contador?") }
    }
}
