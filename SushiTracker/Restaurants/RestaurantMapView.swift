import SwiftUI
import MapKit
import SwiftData

struct RestaurantMapView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SushiRestaurant.visitedAt, order: .reverse) private var savedRestaurants: [SushiRestaurant]

    @StateObject private var location = LocationManager.shared
    @State private var position: MapCameraPosition = .automatic
    @State private var nearbyItems: [MKMapItem] = []
    @State private var selectedMapItem: MKMapItem? = nil
    @State private var selectedSaved: SushiRestaurant? = nil
    @State private var showAddSheet = false
    @State private var showDetailSheet = false
    @State private var isSearching = false
    @State private var addFromMapItem: MKMapItem? = nil

    var body: some View {
        ZStack(alignment: .top) {
            // MAP
            Map(position: $position) {
                // User location
                UserAnnotation()

                // Nearby Google Maps / MapKit results
                ForEach(nearbyItems, id: \.self) { item in
                    Annotation(item.name ?? "Sushi", coordinate: item.placemark.coordinate) {
                        NearbyPin(isSelected: selectedMapItem == item)
                            .onTapGesture {
                                selectedMapItem = item
                                selectedSaved = nil
                                showDetailSheet = true
                            }
                    }
                }

                // Saved restaurants (on-device)
                ForEach(savedRestaurants) { restaurant in
                    Annotation(restaurant.name, coordinate: restaurant.coordinate) {
                        SavedPin(restaurant: restaurant, isSelected: selectedSaved?.id == restaurant.id)
                            .onTapGesture {
                                selectedSaved = restaurant
                                selectedMapItem = nil
                                showDetailSheet = true
                            }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .ignoresSafeArea()
            .task {
                location.requestPermission()
                if let coord = location.userLocation {
                    position = .region(MKCoordinateRegion(center: coord, latitudinalMeters: 3000, longitudinalMeters: 3000))
                }
            }
            .onChange(of: location.userLocation) { _, coord in
                guard let coord else { return }
                if case .automatic = position {
                    position = .region(MKCoordinateRegion(center: coord, latitudinalMeters: 3000, longitudinalMeters: 3000))
                }
                Task { await searchNearby(coord) }
            }

            // Header overlay
            VStack(spacing: 0) {
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
                    Text("Mapa de Sushi")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .glassEffect(in: Capsule())
                    Spacer()
                    Button {
                        addFromMapItem = nil
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 38, height: 38)
                            .glassEffect(in: Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 56)

                // Search button
                if isSearching {
                    ProgressView()
                        .tint(.white)
                        .padding(8)
                        .glassEffect(in: Capsule())
                        .padding(.top, 8)
                } else {
                    Button {
                        if let coord = location.userLocation {
                            Task { await searchNearby(coord) }
                        }
                    } label: {
                        Label("Pesquisar Restaurantes", systemImage: "magnifyingglass")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .glassEffect(in: Capsule())
                    }
                    .padding(.top, 8)
                }
            }

            // Bottom legend
            HStack(spacing: 16) {
                Label("Guardado", systemImage: "star.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                Label("Próximo", systemImage: "mappin")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(savedRestaurants.count) guardados")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .glassEffect(in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 40)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showDetailSheet) {
            if let mapItem = selectedMapItem {
                NearbyRestaurantDetailSheet(mapItem: mapItem) { savedMapItem in
                    addFromMapItem = savedMapItem
                    showDetailSheet = false
                    showAddSheet = true
                }
            } else if let saved = selectedSaved {
                SavedRestaurantDetailSheet(restaurant: saved)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddRestaurantSheet(prefill: addFromMapItem) { restaurant in
                modelContext.insert(restaurant)
                showAddSheet = false
            }
        }
    }

    private func searchNearby(_ coordinate: CLLocationCoordinate2D) async {
        isSearching = true
        nearbyItems = (try? await MKLocalSearch.searchSushiRestaurants(near: coordinate)) ?? []
        isSearching = false
    }
}

// MARK: - Map pins

private struct NearbyPin: View {
    let isSelected: Bool
    var body: some View {
        Image(systemName: "mappin.circle.fill")
            .font(.system(size: isSelected ? 36 : 28))
            .foregroundStyle(isSelected ? Color(hex: "#E63946") : Color(hex: "#FF6B7A"))
            .shadow(radius: 4)
            .animation(.spring(duration: 0.2), value: isSelected)
    }
}

private struct SavedPin: View {
    let restaurant: SushiRestaurant
    let isSelected: Bool
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color(hex: "#FFB700") : Color(hex: "#E63946"))
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                Text("🍣").font(.system(size: isSelected ? 22 : 18))
            }
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            if isSelected {
                Text(restaurant.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .glassEffect(in: Capsule())
            }
        }
        .animation(.spring(duration: 0.2), value: isSelected)
    }
}
