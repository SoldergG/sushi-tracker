import SwiftUI

struct WelcomeView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            Circle()
                .fill(Color(hex: "#E63946").opacity(0.12))
                .frame(width: 400, height: 400)
                .offset(x: 120, y: -280)
                .blur(radius: 40)
            Circle()
                .fill(Color(hex: "#FFB700").opacity(0.07))
                .frame(width: 300, height: 300)
                .offset(x: -120, y: 280)
                .blur(radius: 40)

            VStack(spacing: 0) {
                Spacer()

                // Logo
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 100, height: 100)
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1.5))
                        Text("🍣").font(.system(size: 44))
                    }
                    Text("Sushi Tracker")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("Conte cada peça do seu rodízio")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 48)

                // Features
                VStack(spacing: 14) {
                    FeatureRow(emoji: "📊", text: "Estatísticas detalhadas")
                    FeatureRow(emoji: "👥", text: "Compartilhe com amigos")
                    FeatureRow(emoji: "⚡", text: "Modo contínuo sem pausas")
                }
                .padding(.bottom, 40)

                // Buttons
                VStack(spacing: 14) {
                    NavigationLink {
                        SignUpView()
                    } label: {
                        Text("Criar Conta")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(hex: "#E63946").opacity(0.9))
                            .clipShape(Capsule())
                            .shadow(color: Color(hex: "#E63946").opacity(0.4), radius: 8, y: 4)
                    }

                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("Entrar")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 30)
        }
        .navigationBarHidden(true)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { appeared = true }
        }
    }
}

private struct FeatureRow: View {
    let emoji: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 42, height: 42)
                Text(emoji).font(.system(size: 18))
            }
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}
