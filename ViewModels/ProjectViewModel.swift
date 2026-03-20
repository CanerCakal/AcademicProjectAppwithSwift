import Foundation
import FirebaseFirestore
import Combine

@MainActor
class ProjectViewModel: ObservableObject {
    // Projeleri tutacağımız dizi. Veri geldiğinde arayüz otomatik güncellenecek.
    @Published var projects: [Project] = []
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    // Veritabanından projeleri çeken fonksiyon
    func fetchProjects() async {
        do {
            // "projects" koleksiyonundaki tüm dokümanları getir
            let snapshot = try await db.collection("projects").getDocuments()
            
            var loadedProjects: [Project] = []
            
            for document in snapshot.documents {
                do {
                    // Veriyi modelimize çevirmeyi deniyoruz
                    let project = try document.data(as: Project.self)
                    loadedProjects.append(project)
                } catch {
                    // Eğer çevirirken hata olursa Xcode konsoluna yazdır!
                    print("⚠️ DİKKAT: \(document.documentID) ID'li proje çevrilemedi!")
                    print("Hata detayı: \(error)")
                }
            }
            
            self.projects = loadedProjects
            
        } catch {
            print("❌ Veritabanına ulaşılamadı: \(error.localizedDescription)")
            self.errorMessage = "Projeler yüklenirken hata oluştu: \(error.localizedDescription)"
        }
    }
}
