import SwiftUI

struct SushiListView: View {
    @State private var sushiTypes = SushiTypeEntry.defaults
    @State private var showAddSheet = false
    @State private var newName = ""
    @State private var showResetAlert = false
    @State private var deleteTarget: SushiTypeEntry? = nil

    private var totalPieces: Int { sushiTypes.reduce(0) { $0 + $1.pieces } }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0d1a0d"), Color(hex: "#1a3a1a"), Color(hex: "#0d0d1a")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            Circle()
                .fill(Color(hex: "#28a745").opacity(0.2))
                .frame(width: 350, height: 350)
                .offset(x: 120, y: -200)
                .blur(radius: 60)

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Lista de Sushi")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20).padding(.vertical, 16)

                // Stats bar
                HStack {
                    Text("Total: \(totalPieces) peças")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button { showResetAlert = true } label: {
                        Text("Reiniciar Tudo")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .glassEffect(in: Capsule())
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 12)

                // List
                ScrollView {
                    GlassEffectContainer {
                        VStack(spacing: 10) {
                            ForEach($sushiTypes) { $sushi in
                                SushiListRow(sushi: $sushi, onDelete: { deleteTarget = sushi })
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 90)
                }
            }

            // FAB
            Button { showAddSheet = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(hex: "#28a745"))
                    .clipShape(Circle())
                    .shadow(color: Color(hex: "#28a745").opacity(0.4), radius: 12, y: 6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding(24)
        }
        .navigationBarHidden(true)
        .alert("Reiniciar Todos os Contadores", isPresented: $showResetAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Reiniciar", role: .destructive) {
                sushiTypes = sushiTypes.map { SushiTypeEntry(id: $0.id, name: $0.name, pieces: 0) }
            }
        } message: { Text("Tem certeza que deseja reiniciar todos os contadores para zero?") }
        .alert(
            "Apagar Tipo de Sushi",
            isPresented: Binding(get: { deleteTarget != nil }, set: { if !$0 { deleteTarget = nil } })
        ) {
            Button("Cancelar", role: .cancel) { deleteTarget = nil }
            Button("Apagar", role: .destructive) {
                if let t = deleteTarget { sushiTypes.removeAll { $0.id == t.id } }
                deleteTarget = nil
            }
        } message: { Text("Tem certeza que deseja apagar \"\(deleteTarget?.name ?? "")\"?") }
        .sheet(isPresented: $showAddSheet) {
            AddSushiSheet(name: $newName) {
                guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                sushiTypes.append(SushiTypeEntry(name: newName.trimmingCharacters(in: .whitespaces)))
                newName = ""; showAddSheet = false
            }
        }
    }
}

// MARK: - Row

private struct SushiListRow: View {
    @Binding var sushi: SushiTypeEntry
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(sushi.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text("\(sushi.pieces) peças")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.65))
            }
            Spacer()
            HStack(spacing: 10) {
                Button {
                    if sushi.pieces > 0 { sushi.pieces -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .glassEffect(in: Circle())
                }
                Button { sushi.pieces += 1 } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .glassEffect(in: Circle())
                }
                Button { onDelete() } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 30, height: 30)
                        .glassEffect(in: Circle())
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Add Sheet

private struct AddSushiSheet: View {
    @Binding var name: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Nome do sushi", text: $name)
                    .padding(14)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    onAdd()
                } label: {
                    Text("Adicionar")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "#28a745"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Spacer()
            }
            .padding(20)
            .navigationTitle("Adicionar Tipo de Sushi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
        .presentationDetents([.height(240)])
    }
}
