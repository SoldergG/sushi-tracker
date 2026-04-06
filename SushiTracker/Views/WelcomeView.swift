import SwiftUI

struct WelcomeView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Vibrant gradient background — makes glass pop
            LinearGradient(
                colors: [Color(hex: "#1a0010"), Color(hex: "#2d0a1a"), Color(hex: "#0d0d1a")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(hex: "#E63946").opacity(0.35))
                .frame(width: 420, height: 420)
                .offset(x: 130, y: -300)
                .blur(radius: 60)
            Circle()
                .fill(Color(hex: "#FFB700").opacity(0.18))
                .frame(width: 300, height: 300)
                .offset(x: -130, y: 300)
                .blur(radius: 50)

            VStack(spacing: 0) {
                Spacer()

                // Logo
                VStack(spacing: 14) {
                    Text("🍣")
                        .font(.system(size: 52))
                        .padding(24)
                        .glassEffect(in: Circle())

                    Text("Sushi Tracker")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Conte cada peça do seu rodízio")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 48)

                // Features — GlassEffectContainer merges the 3 glass rows
                GlassEffectContainer {
                    VStack(spacing: 10) {
                        FeatureRow(emoji: "📊", text: "Estatísticas detalhadas")
                        FeatureRow(emoji: "👥", text: "Compartilhe com amigos")
                        FeatureRow(emoji: "⚡", text: "Modo contínuo sem pausas")
                    }
                }
                .padding(.bottom, 40)

                // Buttons
                VStack(spacing: 14) {
                    NavigationLink {
                        SignUpView()
                    } label: {
                        Text("Criar Conta")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(hex: "#E63946"))
                            .clipShape(Capsule())
                            .shadow(color: Color(hex: "#E63946").opacity(0.5), radius: 12, y: 6)
                    }

                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("Entrar")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .glassEffect(in: Capsule())
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
            Text(emoji).font(.system(size: 20))
                .frame(width: 36, height: 36)
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
    }
}
