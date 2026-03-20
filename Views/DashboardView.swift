import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    // Projeleri yönetecek sınıfımızı ekliyoruz
    @StateObject private var projectViewModel = ProjectViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Arka plan rengi
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack {
                    // Üst Bilgi Alanı
                    if let user = authViewModel.currentUser {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Hoş Geldin,")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(user.fullName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            Button(action: { authViewModel.logout() }) {
                                Text("Çıkış")
                                    .font(.footnote)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.red.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Projeler Listesi
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            if projectViewModel.projects.isEmpty {
                                Text("Henüz hiç proje yok veya yükleniyor...")
                                    .foregroundColor(.gray)
                                    .padding(.top, 50)
                            } else {
                                ForEach(projectViewModel.projects) { project in
                                    ProjectCardView(project: project)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            // Ekran açılır açılmaz projeleri çek
            .task {
                await projectViewModel.fetchProjects()
            }
        }
    }
}

// Proje Kartı Tasarımı (Eski HTML projesindeki data-card mantığı)
struct ProjectCardView: View {
    var project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(project.title)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text(project.status.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(6)
                    .background(statusColor(for: project.status))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Text(project.summary ?? "Bu proje için henüz bir özet girilmemiş.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Duruma göre renk veren yardımcı fonksiyon
    func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "approved": return .green
        case "development": return .orange
        case "proposal": return .blue
        case "rejected": return .red
        default: return .gray
        }
    }
}
