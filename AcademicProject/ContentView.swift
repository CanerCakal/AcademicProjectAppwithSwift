import SwiftUI

struct ContentView: View {
    // ViewModel'imizi burada tek bir defa oluşturuyoruz (StateObject)
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            // Kullanıcı giriş yapmış mı?
            if authViewModel.isAuthenticated {
                DashboardView()
            } else {
                LoginView()
            }
        }
        // Oluşturduğumuz bu viewModel'i tüm alt görünümlere (.environmentObject ile) paylaşıyoruz
        .environmentObject(authViewModel)
    }
}
