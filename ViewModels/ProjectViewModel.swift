import Combine
import FirebaseFirestore
import Foundation

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
                    print(
                        "⚠️ DİKKAT: \(document.documentID) ID'li proje çevrilemedi!"
                    )
                    print("Hata detayı: \(error)")
                }
            }
            
            self.projects = loadedProjects
            
        } catch {
            print("❌ Veritabanına ulaşılamadı: \(error.localizedDescription)")
            self.errorMessage =
            "Projeler yüklenirken hata oluştu: \(error.localizedDescription)"
        }
    }
    
    // Yeni proje ekleme fonksiyonu
    func addProject(
        title: String,
        summary: String,
        courseId: String,
        createdBy: String
    ) async {
        // 1. Yeni proje nesnesini oluşturuyoruz (Status her zaman "proposal" yani "Öneri" olarak başlar)
        let newProject = Project(
            title: title,
            summary: summary,
            status: "proposal",
            courseId: courseId,
            createdBy: createdBy
        )
        
        do {
            // 2. Nesneyi Firestore'a "projects" koleksiyonu altına otomatik ID ile ekle
            let _ = try db.collection("projects").addDocument(from: newProject)
            
            // 3. Ekleme başarılı olursa listeyi yenile ki ekranda hemen görünsün!
            await fetchProjects()
        } catch {
            self.errorMessage =
            "Proje kaydedilemedi: \(error.localizedDescription)"
        }
    }
    
    func updateProjectStatus(projectId: String, newStatus: String) async {
        do {
            try await db.collection("projects").document(projectId).updateData([
                "status": newStatus
            ])
            await fetchProjects()
        } catch {
            self.errorMessage =
            "Durum güncellenirken hata oluştu: \(error.localizedDescription)"
        }
    }
    
    func deleteProject(projectId: String) async {
        do {
            try await db.collection("projects").document(projectId).delete()
            await fetchProjects()
        } catch {
            self.errorMessage = "Proje silinirken hata oluştu: \(error.localizedDescription)"
        }
    }
    
    func updateProject(projectId: String, title: String, summary: String) async {
        do {
            try await db.collection("projects").document(projectId).updateData([
                "title": title,
                "summary": summary
            ])
            await fetchProjects()
        } catch {
            self.errorMessage = "Proje güncellenirken hata oluştu: \(error.localizedDescription)"
        }
    }
}
