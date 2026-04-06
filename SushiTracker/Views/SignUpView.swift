import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#1a0010"), Color(hex: "#2d0a1a"), Color(hex: "#0d0d1a")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            Circle()
                .fill(Color(hex: "#E63946").opacity(0.3))
                .frame(width: 350, height: 350)
                .offset(x: 100, y: -220)
                .blur(radius: 55)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    Text("🍣")
                        .font(.system(size: 34))
                        .padding(20)
                        .glassEffect(in: Circle())
                    Text("Criar conta")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Junte-se à comunidade sushi")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.bottom, 40)

                GlassEffectContainer {
                    VStack(spacing: 14) {
                        AuthField(placeholder: "Nome completo", text: $name)
                        AuthField(placeholder: "Email", text: $email, keyboard: .emailAddress)
                        AuthField(placeholder: "Password (mínimo 6 caracteres)", text: $password, isSecure: true)
                    }
                }
                .padding(.bottom, 18)

                if let err = errorMessage {
                    Text(err)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "#ff6b7a"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                }

                Button {
                    Task { await handleSignUp() }
                } label: {
                    Group {
                        if isLoading { ProgressView().tint(.white) }
                        else { Text("Criar Conta").font(.system(size: 18, weight: .bold)) }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(isLoading ? Color.white.opacity(0.15) : Color(hex: "#E63946"))
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "#E63946").opacity(isLoading ? 0 : 0.4), radius: 10, y: 5)
                }
                .disabled(isLoading)
                .padding(.bottom, 24)

                HStack {
                    Rectangle().fill(.white.opacity(0.15)).frame(height: 1)
                    Text("ou").font(.system(size: 13)).foregroundStyle(.white.opacity(0.4))
                    Rectangle().fill(.white.opacity(0.15)).frame(height: 1)
                }
                .padding(.bottom, 18)

                Button { dismiss() } label: {
                    (Text("Já tem conta? ").foregroundStyle(.white.opacity(0.6)) +
                     Text("Faça login").foregroundStyle(.white).bold())
                    .font(.system(size: 14))
                }

                Spacer()
            }
            .padding(.horizontal, 30)
        }
        .navigationBarHidden(true)
        .opacity(appeared ? 1 : 0)
        .onAppear { withAnimation(.easeOut(duration: 0.6)) { appeared = true } }
        .alert("Conta criada!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("A sua conta foi criada. Pode agora fazer login.")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                        .padding(8)
                        .glassEffect(in: Circle())
                }
            }
        }
    }

    private func handleSignUp() async {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, preencha todos os campos"; return
        }
        guard password.count >= 6 else {
            errorMessage = "A password deve ter pelo menos 6 caracteres"; return
        }
        isLoading = true; errorMessage = nil
        do { try await auth.signUp(email: email, password: password, name: name); showSuccess = true }
        catch { errorMessage = error.localizedDescription }
        isLoading = false
    }
}
