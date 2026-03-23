import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isCheckingAuth {
                // Uygulama açıldığında saniyelik de olsa görünecek şık bekleme ekranı
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Oturum kontrol ediliyor...")
                        .foregroundColor(.gray)
                }
            } else if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
    }
}
