import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isCheckingAuth {
                ProgressView()
                    .scaleEffect(1.5)
            } else if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
    }
}
