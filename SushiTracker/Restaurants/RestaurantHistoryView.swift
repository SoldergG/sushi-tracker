import SwiftUI
import SwiftData

struct RestaurantHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SushiRestaurant.visitedAt, order: .reverse) private var restaurants: [SushiRestaurant]

    @State private var selectedRestaurant: SushiRestaurant? = nil

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#1a0010"), Color(hex: "#2d0020"), Color(hex: "#0d0d1a")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            Circle()
                .fill(Color(hex: "#FFB700").opacity(0.15))
                .frame(width: 350, height: 350)
                .offset(x: 120, y: -200)
                .blur(radius: 60)

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
                    Text("Histórico")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer().frame(width: 80)
                }
                .padding(.horizontal, 20).padding(.vertical, 16)

                if restaurants.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("🍣")
                            .font(.system(size: 60))
                        Text("Sem restaurantes ainda")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Guarda o teu próximo restaurante de sushi no mapa!")
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        GlassEffectContainer {
                            VStack(spacing: 10) {
                                ForEach(restaurants) { restaurant in
                                    Button { selectedRestaurant = restaurant } label: {
                                        RestaurantHistoryRow(restaurant: restaurant)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedRestaurant) { restaurant in
            SavedRestaurantDetailSheet(restaurant: restaurant)
        }
    }
}

// MARK: - Row

private struct RestaurantHistoryRow: View {
    let restaurant: SushiRestaurant

    var body: some View {
        HStack(spacing: 14) {
            Text("🍣")
                .font(.system(size: 28))
                .frame(width: 44, height: 44)
                .glassEffect(in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                if !restaurant.address.isEmpty {
                    Text(restaurant.address)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }
                Text(restaurant.visitedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.45))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= restaurant.rating ? "star.fill" : "star")
                            .font(.system(size: 11))
                            .foregroundStyle(i <= restaurant.rating ? Color(hex: "#FFB700") : .white.opacity(0.25))
                    }
                }
                if restaurant.totalPiecesEaten > 0 {
                    Text("\(restaurant.totalPiecesEaten) peças")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.35))
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .glassEffect(in: RoundedRectangle(cornerRadius: 14))
    }
}
