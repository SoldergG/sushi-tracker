import SwiftUI
import MapKit
import SwiftData

// MARK: - Nearby restaurant detail (from MapKit search)

struct NearbyRestaurantDetailSheet: View {
    let mapItem: MKMapItem
    let onSave: (MKMapItem) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1a0010").ignoresSafeArea()
                Circle()
                    .fill(Color(hex: "#E63946").opacity(0.2))
                    .frame(width: 300, height: 300)
                    .offset(x: 100, y: -100).blur(radius: 50)

                VStack(alignment: .leading, spacing: 20) {
                    // Name & address
                    VStack(alignment: .leading, spacing: 8) {
                        Text(mapItem.name ?? "Restaurante")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        if let addr = mapItem.placemark.formattedAddress {
                            Text(addr)
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 16))

                    // Mini map preview
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: mapItem.placemark.coordinate,
                        latitudinalMeters: 500, longitudinalMeters: 500
                    ))) {
                        Annotation(mapItem.name ?? "", coordinate: mapItem.placemark.coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Color(hex: "#E63946"))
                        }
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .disabled(true)

                    // Open in Maps button
                    Button {
                        mapItem.openInMaps()
                    } label: {
                        Label("Abrir no Maps", systemImage: "map")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                    }

                    // Save button
                    Button { onSave(mapItem) } label: {
                        Label("Guardar no Histórico", systemImage: "star.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#E63946"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color(hex: "#E63946").opacity(0.4), radius: 10, y: 5)
                    }

                    Spacer()
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                            .padding(6)
                            .glassEffect(in: Circle())
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Saved restaurant detail

struct SavedRestaurantDetailSheet: View {
    @Bindable var restaurant: SushiRestaurant
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1a0010").ignoresSafeArea()
                Circle()
                    .fill(Color(hex: "#FFB700").opacity(0.2))
                    .frame(width: 300, height: 300)
                    .offset(x: 100, y: -100).blur(radius: 50)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Name & date
                        VStack(alignment: .leading, spacing: 6) {
                            Text(restaurant.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                            Text(restaurant.address)
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.7))
                            Text("Visitado em \(restaurant.visitedAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 16))

                        // Mini map
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: restaurant.coordinate,
                            latitudinalMeters: 500, longitudinalMeters: 500
                        ))) {
                            Annotation(restaurant.name, coordinate: restaurant.coordinate) {
                                Text("🍣").font(.system(size: 28))
                            }
                        }
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .disabled(true)

                        // Stats
                        HStack(spacing: 12) {
                            GlassEffectContainer {
                                HStack(spacing: 12) {
                                    VStack(spacing: 4) {
                                        Text("\(restaurant.totalPiecesEaten)")
                                            .font(.system(size: 26, weight: .bold)).foregroundStyle(.white)
                                        Text("Peças").font(.system(size: 12)).foregroundStyle(.white.opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(16)
                                    .glassEffect(in: RoundedRectangle(cornerRadius: 12))

                                    VStack(spacing: 4) {
                                        HStack(spacing: 2) {
                                            ForEach(1...5, id: \.self) { i in
                                                Image(systemName: i <= restaurant.rating ? "star.fill" : "star")
                                                    .font(.system(size: 14))
                                                    .foregroundStyle(i <= restaurant.rating ? Color(hex: "#FFB700") : .white.opacity(0.3))
                                            }
                                        }
                                        Text("Avaliação").font(.system(size: 12)).foregroundStyle(.white.opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(16)
                                    .glassEffect(in: RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }

                        // Rating editor
                        VStack(alignment: .leading, spacing: 10) {
                            Text("A tua avaliação")
                                .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                            HStack(spacing: 10) {
                                ForEach(1...5, id: \.self) { i in
                                    Button { restaurant.rating = i } label: {
                                        Image(systemName: i <= restaurant.rating ? "star.fill" : "star")
                                            .font(.system(size: 28))
                                            .foregroundStyle(i <= restaurant.rating ? Color(hex: "#FFB700") : .white.opacity(0.4))
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 14))

                        // Notes editor
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notas")
                                .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                            TextField("Adicionar notas...", text: $restaurant.notes, axis: .vertical)
                                .foregroundStyle(.white)
                                .lineLimit(3...6)
                        }
                        .padding(16)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 14))

                        // Open in Maps
                        Button {
                            let item = MKMapItem(placemark: MKPlacemark(coordinate: restaurant.coordinate))
                            item.name = restaurant.name
                            item.openInMaps()
                        } label: {
                            Label("Abrir no Maps", systemImage: "map")
                                .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                        }

                        // Delete
                        Button { showDeleteConfirm = true } label: {
                            Label("Apagar do Histórico", systemImage: "trash")
                                .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white.opacity(0.8))
                                .frame(maxWidth: .infinity).padding(.vertical, 14)
                                .glassEffect(in: RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundStyle(.white)
                            .padding(6).glassEffect(in: Circle())
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .alert("Apagar Restaurante", isPresented: $showDeleteConfirm) {
            Button("Cancelar", role: .cancel) {}
            Button("Apagar", role: .destructive) {
                modelContext.delete(restaurant)
                dismiss()
            }
        } message: { Text("Tem certeza que deseja apagar \"\(restaurant.name)\"?") }
    }
}

// MARK: - Add restaurant sheet

struct AddRestaurantSheet: View {
    let prefill: MKMapItem?
    let onSave: (SushiRestaurant) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var address: String
    @State private var rating = 3
    @State private var notes = ""
    @State private var pieces = ""
    @State private var latitude: Double
    @State private var longitude: Double

    init(prefill: MKMapItem?, onSave: @escaping (SushiRestaurant) -> Void) {
        self.prefill = prefill
        self.onSave = onSave
        _name = State(initialValue: prefill?.name ?? "")
        _address = State(initialValue: prefill?.placemark.formattedAddress ?? "")
        _latitude = State(initialValue: prefill?.placemark.coordinate.latitude ?? 0)
        _longitude = State(initialValue: prefill?.placemark.coordinate.longitude ?? 0)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1a0010").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        GlassEffectContainer {
                            VStack(spacing: 12) {
                                GlassTextField(label: "Nome do restaurante", text: $name)
                                GlassTextField(label: "Morada", text: $address)
                                GlassTextField(label: "Peças comidas (opcional)", text: $pieces, keyboard: .numberPad)
                                GlassTextField(label: "Notas (opcional)", text: $notes)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Avaliação")
                                .font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { i in
                                    Button { rating = i } label: {
                                        Image(systemName: i <= rating ? "star.fill" : "star")
                                            .font(.system(size: 30))
                                            .foregroundStyle(i <= rating ? Color(hex: "#FFB700") : .white.opacity(0.3))
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassEffect(in: RoundedRectangle(cornerRadius: 14))

                        Button {
                            guard !name.isEmpty else { return }
                            let restaurant = SushiRestaurant(
                                name: name,
                                address: address,
                                latitude: latitude,
                                longitude: longitude,
                                rating: rating,
                                notes: notes,
                                totalPiecesEaten: Int(pieces) ?? 0
                            )
                            onSave(restaurant)
                        } label: {
                            Label("Guardar Restaurante", systemImage: "star.fill")
                                .font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Color(hex: "#E63946"))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: Color(hex: "#E63946").opacity(0.4), radius: 10, y: 5)
                        }
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Adicionar Restaurante")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundStyle(.white)
                            .padding(6).glassEffect(in: Circle())
                    }
                }
            }
        }
        .presentationDetents([.large])
    }
}

// MARK: - Glass text field helper for sheets

private struct GlassTextField: View {
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        TextField(label, text: $text)
            .keyboardType(keyboard)
            .foregroundStyle(.white)
            .padding(14)
            .glassEffect(in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - CLPlacemark formatted address

extension CLPlacemark {
    var formattedAddress: String? {
        [subThoroughfare, thoroughfare, locality, administrativeArea, isoCountryCode]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
            .nilIfEmpty
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
