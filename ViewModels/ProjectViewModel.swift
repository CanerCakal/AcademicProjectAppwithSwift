import Combine
import Foundation

@MainActor
class ProjectViewModel: ObservableObject {

    @Published var projects: [Project] = []
    @Published var errorMessage: String?

    private let service: ProjectServiceProtocol
    private var listenerTask: Task<Void, Never>?

    init(service: ProjectServiceProtocol = FirestoreProjectService()) {
        self.service = service
    }

    func startListening() {
        listenerTask?.cancel()
        listenerTask = Task {
            for await updatedProjects in service.projectsStream() {
                self.projects = updatedProjects
            }
        }
    }

    func stopListening() {
        listenerTask?.cancel()
        listenerTask = nil
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
        } catch {
            self.errorMessage = "Proje kaydedilemedi: \(error.localizedDescription)"
        }
    }

    func updateProjectStatus(projectId: String, newStatus: ProjectStatus) async {
        do {
            try await service.updateStatus(projectId: projectId, newStatus: newStatus)
        } catch {
            self.errorMessage = "Durum güncellenirken hata oluştu: \(error.localizedDescription)"
        }
    }

    func deleteProject(projectId: String) async {
        do {
            try await service.deleteProject(projectId: projectId)
        } catch {
            self.errorMessage = "Proje silinirken hata oluştu: \(error.localizedDescription)"
        }
    }

    func updateProject(projectId: String, title: String, summary: String) async {
        do {
            try await service.updateProject(projectId: projectId, title: title, summary: summary)
        } catch {
            self.errorMessage = "Proje güncellenirken hata oluştu: \(error.localizedDescription)"
        }
    }

    deinit {
        listenerTask?.cancel()
    }
}
