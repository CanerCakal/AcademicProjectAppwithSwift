import Combine
import Foundation

@MainActor
class ProjectViewModel: ObservableObject {

    @Published var projects: [Project] = []
    @Published var errorMessage: String?

    private let service: ProjectServiceProtocol

    init(service: ProjectServiceProtocol = FirestoreProjectService()) {
        self.service = service
    }

    func fetchProjects() async {
        do {
            self.projects = try await service.fetchProjects()
        } catch {
            self.errorMessage = "Projeler yüklenirken hata oluştu: \(error.localizedDescription)"
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
            status: .proposal,
            courseId: courseId,
            createdBy: createdBy
        )

        do {
            try await service.addProject(newProject)
            await fetchProjects()
        } catch {
            self.errorMessage = "Proje kaydedilemedi: \(error.localizedDescription)"
        }
    }

    func updateProjectStatus(projectId: String, newStatus: ProjectStatus) async {
        do {
            try await service.updateStatus(projectId: projectId, newStatus: newStatus)
            await fetchProjects()
        } catch {
            self.errorMessage = "Durum güncellenirken hata oluştu: \(error.localizedDescription)"
        }
    }

    func deleteProject(projectId: String) async {
        do {
            try await service.deleteProject(projectId: projectId)
            await fetchProjects()
        } catch {
            self.errorMessage = "Proje silinirken hata oluştu: \(error.localizedDescription)"
        }
    }

    func updateProject(projectId: String, title: String, summary: String) async {
        do {
            try await service.updateProject(projectId: projectId, title: title, summary: summary)
            await fetchProjects()
        } catch {
            self.errorMessage = "Proje güncellenirken hata oluştu: \(error.localizedDescription)"
        }
    }
}
