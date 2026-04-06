import SwiftUI

struct SushiListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sushiTypes = SushiTypeEntry.defaults
    @State private var showAddSheet = false
    @State private var newName = ""
    @State private var showResetAlert = false
    @State private var deleteTarget: SushiTypeEntry? = nil

    private var totalPieces: Int {
        sushiTypes.reduce(0) { $0 + $1.pieces }
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
                Text("Lista de Sushi")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer().frame(width: 70)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(hex: "#6c757d"))

            // Stats bar
            HStack {
                Text("Total: \(totalPieces) peças")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#333333"))
                Spacer()
                Button { showResetAlert = true } label: {
                    Text("Reiniciar Tudo")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#dc3545"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.white)
            .overlay(Rectangle().frame(height: 1).foregroundColor(Color(hex: "#eeeeee")), alignment: .bottom)

            // List
            List {
                ForEach($sushiTypes) { $sushi in
                    SushiListRow(sushi: $sushi, onDelete: {
                        deleteTarget = sushi
                    })
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(hex: "#f8f9fa"))
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
            }
            .listStyle(.plain)
            .background(Color(hex: "#f8f9fa"))
            .scrollContentBackground(.hidden)
        }
        .background(Color(hex: "#f8f9fa"))
        .navigationBarHidden(true)
        .overlay(alignment: .bottomTrailing) {
            Button { showAddSheet = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(hex: "#28a745"))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
            }
            .padding(24)
        }
        .alert("Reiniciar Todos os Contadores", isPresented: $showResetAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Reiniciar", role: .destructive) {
                sushiTypes = sushiTypes.map { SushiTypeEntry(id: $0.id, name: $0.name, pieces: 0) }
            }
        } message: {
            Text("Tem certeza que deseja reiniciar todos os contadores para zero?")
        }
        .alert(
            "Apagar Tipo de Sushi",
            isPresented: Binding(get: { deleteTarget != nil }, set: { if !$0 { deleteTarget = nil } })
        ) {
            Button("Cancelar", role: .cancel) { deleteTarget = nil }
            Button("Apagar", role: .destructive) {
                if let t = deleteTarget {
                    sushiTypes.removeAll { $0.id == t.id }
                }
                deleteTarget = nil
            }
        } message: {
            Text("Tem certeza que deseja apagar \"\(deleteTarget?.name ?? "")\"?")
        }
        .sheet(isPresented: $showAddSheet) {
            AddSushiSheet(name: $newName) {
                guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                sushiTypes.append(SushiTypeEntry(name: newName.trimmingCharacters(in: .whitespaces)))
                newName = ""
                showAddSheet = false
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
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#333333"))
                Text("\(sushi.pieces) peças")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#666666"))
            }
            Spacer()
            HStack(spacing: 10) {
                Button {
                    if sushi.pieces > 0 { sushi.pieces -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color(hex: "#dc3545"))
                        .clipShape(Circle())
                }
                Button {
                    sushi.pieces += 1
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color(hex: "#28a745"))
                        .clipShape(Circle())
                }
                Button { onDelete() } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color(hex: "#6c757d"))
                        .clipShape(Circle())
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
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
                    .background(Color(hex: "#f8f9fa"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#dddddd"), lineWidth: 1))

                Button {
                    onAdd()
                } label: {
                    Text("Adicionar")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
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
