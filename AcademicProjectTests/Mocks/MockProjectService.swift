import Foundation
@testable import AcademicProject

final class MockProjectService: ProjectServiceProtocol {
    var projectsToReturn: [Project] = []
    var shouldThrow = false

    private(set) var addProjectCalled = false
    private(set) var updateStatusCalled = false
    private(set) var lastStatusSet: ProjectStatus?

    enum MockError: Error { case failed }

    func fetchProjects() async throws -> [Project] {
        if shouldThrow { throw MockError.failed }
        return projectsToReturn
    }

    func projectsStream() -> AsyncStream<[Project]> {
        AsyncStream { continuation in
            continuation.yield(projectsToReturn)
            continuation.finish()
        }
    }

    func addProject(_ project: Project) async throws {
        if shouldThrow { throw MockError.failed }
        addProjectCalled = true
        projectsToReturn.append(project)
    }

    func updateStatus(projectId: String, newStatus: ProjectStatus) async throws {
        if shouldThrow { throw MockError.failed }
        updateStatusCalled = true
        lastStatusSet = newStatus
    }

    func updateProject(projectId: String, title: String, summary: String) async throws {
        if shouldThrow { throw MockError.failed }
    }

    func deleteProject(projectId: String) async throws {
        if shouldThrow { throw MockError.failed }
    }
}
