import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var projectViewModel = ProjectViewModel()

    var body: some View {
        if let user = authViewModel.currentUser {
            TabView {
                DashboardView()
                    .tabItem {
                        Label(
                            "Projeler",
                            systemImage: "list.dash.header.rectangle"
                        )
                    }
                if user.roleId == 1 {
                    AdminPanelView()
                        .tabItem {
                            Label("Yönetim", systemImage: "gearshape.fill")
                        }
                }
                if user.roleId == 2 {
                    TeacherDashboardView()
                        .tabItem {
                            Label("Onaylar", systemImage: "checkmark.seal.fill")
                        }
                }
                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person.fill")
                    }
            }
            .tint(.appPrimary)
            .environmentObject(projectViewModel)
            .task {
                projectViewModel.startListening()
            }
        } else {
            ProgressView("Veriler Yükleniyor...")
        }
    }
}
