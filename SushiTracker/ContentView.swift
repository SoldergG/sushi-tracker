import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        Group {
            if auth.isLoading {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 16) {
                        Text("🍣").font(.system(size: 60))
                        ProgressView().tint(.white)
                    }
                }
            } else if auth.isAuthenticated {
                NavigationStack {
                    HomeView()
                }
            } else {
                NavigationStack {
                    WelcomeView()
                }
            }
        }
    }
}
