import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Início", systemImage: "house.fill") }

            NavigationStack { SushiSessionView() }
                .tabItem { Label("Sessão", systemImage: "fork.knife") }

            NavigationStack { SushiListView() }
                .tabItem { Label("Lista", systemImage: "list.bullet") }

            NavigationStack { RestaurantMapView() }
                .tabItem { Label("Mapa", systemImage: "map.fill") }

            NavigationStack { RestaurantHistoryView() }
                .tabItem { Label("Histórico", systemImage: "star.fill") }
        }
        .tint(Color(hex: "#E63946"))
    }
}
