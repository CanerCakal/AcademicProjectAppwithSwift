import SwiftUI

struct TeacherDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var projectViewModel = ProjectViewModel()

    var pendingProjects: [Project] {
        projectViewModel.projects.filter { $0.status == "proposal" }
    }

    var body: some View {
        NavigationStack {
            Group {
                if pendingProjects.isEmpty {
                    ContentUnavailableView(
                        "Onay Bekleyen Yok",
                        systemImage: "checkmark.circle",
                        description: Text("Şu an onay bekleyen proje bulunmuyor.")
                    )
                } else {
                    List(pendingProjects) { project in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(project.title)
                                .font(.headline)

                            if let description = project.summary {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 12) {
                                Button {
                                    Task {
                                        await projectViewModel.updateProjectStatus(
                                            projectId: project.id ?? "",
                                            newStatus: "approved"
                                        )
                                    }
                                } label: {
                                    Label("Onayla", systemImage: "checkmark")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.green)

                                Button {
                                    Task {
                                        await projectViewModel.updateProjectStatus(
                                            projectId: project.id ?? "",
                                            newStatus: "rejected"
                                        )
                                    }
                                } label: {
                                    Label("Reddet", systemImage: "xmark")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Onay Bekleyenler")
            .task {
                await projectViewModel.fetchProjects()
            }
        }
    }
}
