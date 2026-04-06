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
            Color.black.ignoresSafeArea()
            Circle()
                .fill(Color(hex: "#E63946").opacity(0.1))
                .frame(width: 350, height: 350)
                .offset(x: 100, y: -200)
                .blur(radius: 40)

            VStack(spacing: 0) {
                Spacer()

                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1.5))
                        Text("🍣").font(.system(size: 32))
                    }
                    Text("Criar conta")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Junte-se à comunidade sushi")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 40)

                // Form
                VStack(spacing: 18) {
                    AuthField(placeholder: "Nome completo", text: $name)
                    AuthField(placeholder: "Email", text: $email, isSecure: false, keyboard: .emailAddress)
                    AuthField(placeholder: "Password (mínimo 6 caracteres)", text: $password, isSecure: true)

                    if let err = errorMessage {
                        Text(err)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#E63946"))
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task { await handleSignUp() }
                    } label: {
                        Group {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Criar Conta").font(.system(size: 18, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(isLoading ? Color.white.opacity(0.2) : Color(hex: "#E63946").opacity(0.9))
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "#E63946").opacity(isLoading ? 0 : 0.3), radius: 8, y: 4)
                    }
                    .disabled(isLoading)

                    HStack {
                        Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                        Text("ou").font(.system(size: 13)).foregroundColor(.white.opacity(0.5))
                        Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                    }
                    .padding(.vertical, 4)

                    Button { dismiss() } label: {
                        Group {
                            Text("Já tem conta? ").foregroundColor(.white.opacity(0.7)) +
                            Text("Faça login").foregroundColor(.white).bold()
                        }
                        .font(.system(size: 14))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 30)
        }
        .navigationBarHidden(true)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appeared = true }
        }
        .alert("Conta criada!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("A sua conta foi criada com sucesso. Pode agora fazer login.")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
    }

    private func handleSignUp() async {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, preencha todos os campos"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "A password deve ter pelo menos 6 caracteres"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await auth.signUp(email: email, password: password, name: name)
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
