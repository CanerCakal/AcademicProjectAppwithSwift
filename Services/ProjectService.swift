import Foundation
import FirebaseFirestore

protocol ProjectServiceProtocol {
    func fetchProjects() async throws -> [Project]
    func addProject(_ project: Project) async throws
    func updateStatus(projectId: String, newStatus: ProjectStatus) async throws
    func updateProject(projectId: String, title: String, summary: String) async throws
    func deleteProject(projectId: String) async throws
}

final class FirestoreProjectService: ProjectServiceProtocol {
    private let db = Firestore.firestore()
    private let collectionName = "projects"

    func fetchProjects() async throws -> [Project] {
        let snapshot = try await db.collection(collectionName).getDocuments()
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Project.self)
            } catch {
                print("⚠️ DİKKAT: \(document.documentID) ID'li proje çevrilemedi! Hata: \(error)")
                return nil
            }
        }
    }

    func addProject(_ project: Project) async throws {
        try db.collection(collectionName).addDocument(from: project)
    }

    func updateStatus(projectId: String, newStatus: ProjectStatus) async throws {
        try await db.collection(collectionName).document(projectId).updateData([
            "status": newStatus.rawValue
        ])
    }

    func updateProject(projectId: String, title: String, summary: String) async throws {
        try await db.collection(collectionName).document(projectId).updateData([
            "title": title,
            "summary": summary
        ])
    }

    func deleteProject(projectId: String) async throws {
        try await db.collection(collectionName).document(projectId).delete()
    }
}
