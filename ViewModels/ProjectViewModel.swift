import Combine
import FirebaseFirestore
import Foundation

@MainActor
class ProjectViewModel: ObservableObject {
    
    @Published var projects: [Project] = []
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    func fetchProjects() async {
        do {
            let snapshot = try await db.collection("projects").getDocuments()
            
            var loadedProjects: [Project] = []
            
            for document in snapshot.documents {
                do {
                    let project = try document.data(as: Project.self)
                    loadedProjects.append(project)
                } catch {
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
    
    func addProject(
        title: String,
        summary: String,
        courseId: String,
        createdBy: String
    ) async {
        let newProject = Project(
            title: title,
            summary: summary,
            status: "proposal",
            courseId: courseId,
            createdBy: createdBy
        )
        
        do {
            let _ = try db.collection("projects").addDocument(from: newProject)
            
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
