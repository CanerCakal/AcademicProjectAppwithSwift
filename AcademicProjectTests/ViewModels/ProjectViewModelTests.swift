import Testing
@testable import AcademicProject

@MainActor
struct ProjectViewModelTests {

    @Test("Stream başlatılınca projeler yüklenir")
    func startListeningLoadsProjects() async {
        let mock = MockProjectService()
        mock.projectsToReturn = [
            Project(title: "Test 1", summary: nil, status: .proposal, courseId: "c1", createdBy: "u1"),
            Project(title: "Test 2", summary: nil, status: .approved, courseId: "c1", createdBy: "u1")
        ]
        let viewModel = ProjectViewModel(service: mock)

        viewModel.startListening()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(viewModel.projects.count == 2)
    }

    @Test("Statü güncellemesi servise doğru değerle iletilir")
    func updateStatusPassesCorrectValue() async {
        let mock = MockProjectService()
        let viewModel = ProjectViewModel(service: mock)

        await viewModel.updateProjectStatus(projectId: "p1", newStatus: .approved)

        #expect(mock.updateStatusCalled)
        #expect(mock.lastStatusSet == .approved)
    }
}
