import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        // Kullanıcı verisi yüklenene kadar beklet
        if let user = authViewModel.currentUser {
            TabView {
                // SEKME 1: Herkesin göreceği ana projeler ekranı
                DashboardView()
                    .tabItem {
                        Label("Projeler", systemImage: "list.dash.header.rectangle")
                    }
                
                // SEKME 2: SADECE ADMİN (roleId == 1) İSE GÖSTER!
                if user.roleId == 1 {
                    AdminPanelView()
                        .tabItem {
                            Label("Yönetim", systemImage: "gearshape.fill")
                        }
                }
                
                // SEKME 3: Profil Ekranı
                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person.fill")
                    }
            }
        } else {
            // Veri gelene kadar ekranda dönen yükleme ikonu
            ProgressView("Veriler Yükleniyor...")
        }
    }
}
