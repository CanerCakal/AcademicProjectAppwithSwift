import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    // Projeleri yönetecek sınıfımız
    @StateObject private var projectViewModel = ProjectViewModel()
    
    // Yeni Proje Ekleme (Sheet) ekranının açılıp kapanmasını kontrol eden değişken
    @State private var showingAddProject = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Arka plan rengi
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack {
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
                    // Yüzen "+" Butonu (Floating Action Button)
                    .overlay(
                        Group {
                            // Kullanıcı giriş yapmış mı ve rolü 3 (Öğrenci) mü?
                            if let user = authViewModel.currentUser, user.roleId == 3 {
                                Button(action: {
                                    showingAddProject = true
                                }) {
                                    Image(systemName: "plus")
                                        .font(.title.weight(.semibold))
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 4, x: 0, y: 4)
                                }
                                .padding()
                            }
                        },
                        alignment: .bottomTrailing
                    )
                    // Butona basıldığında aşağıdan açılacak form ekranı
                    .sheet(isPresented: $showingAddProject) {
                        AddProjectView(projectViewModel: projectViewModel)
                    }
                }
            }
            .navigationTitle("Projeler") // Üstteki şık başlığımız
            // Ekran ilk açıldığında projeleri veritabanından çekme isteği gönder
            .task {
                await projectViewModel.fetchProjects()
            }
        }
    }
}

// Proje Kartı Tasarımı (Alt Görünüm)
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
            
            // Eğer summary boş (nil) gelirse varsayılan metni göster
            Text(project.summary ?? "Bu proje için henüz bir özet girilmemiş.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3) // Çok uzunsa 3 satırda keser
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Projenin durumuna göre arkaplan rengi veren yardımcı fonksiyon
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
