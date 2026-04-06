import SwiftUI
import UIKit

struct KeepAwakeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var totalPieces = 0
    @State private var isKeepAwakeActive = true
    @State private var showResetAlert = false

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
                Text("Modo Contínuo")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer().frame(width: 70)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(hex: "#FFB700"))

            ScrollView {
                VStack(spacing: 20) {
                    // Status card
                    VStack(spacing: 6) {
                        Text(isKeepAwakeActive ? "⚡ Tela Ativa" : "😴 Tela Normal")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#FFB700"))
                        Text("A tela permanecerá ativa enquanto o modo estiver ativo")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#666666"))
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.07), radius: 6, y: 2)

                    // Counter
                    VStack(spacing: 8) {
                        Text("Peças de Sushi")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "#333333"))
                        Text("\(totalPieces)")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(Color(hex: "#E63946"))
                        Text("toque para adicionar")
                            .font(.system(size: 14))
                            .italic()
                            .foregroundColor(Color(hex: "#999999"))
                    }
                    .padding(.vertical, 10)

                    // +1 button
                    Button {
                        totalPieces += 1
                    } label: {
                        Text("+1 Peça")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color(hex: "#E63946"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(hex: "#E63946").opacity(0.3), radius: 6, y: 3)
                    }

                    // Reset + Toggle
                    HStack(spacing: 14) {
                        Button { showResetAlert = true } label: {
                            Text("🔄 Reiniciar")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: "#dc3545"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        Button {
                            isKeepAwakeActive.toggle()
                            UIApplication.shared.isIdleTimerDisabled = isKeepAwakeActive
                        } label: {
                            Text(isKeepAwakeActive ? "⏸ Pausar" : "▶ Ativar")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(hex: "#6c757d"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Instructions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("📋 Instruções")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#333333"))
                        ForEach([
                            "Toque no botão \"+1 Peça\" para adicionar uma peça",
                            "A tela permanecerá ativa para facilitar a contagem",
                            "Use \"Reiniciar\" para zerar o contador",
                            "\"Pausar\" permite que o dispositivo desligue normalmente",
                        ], id: \.self) { tip in
                            Text("• \(tip)")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#666666"))
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.07), radius: 6, y: 2)
                }
                .padding(16)
            }
        }
        .background(Color(hex: "#f8f9fa"))
        .navigationBarHidden(true)
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .alert("Reiniciar Contador", isPresented: $showResetAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Reiniciar", role: .destructive) { totalPieces = 0 }
        } message: {
            Text("Tem certeza que deseja reiniciar o contador?")
        }
    }
}
