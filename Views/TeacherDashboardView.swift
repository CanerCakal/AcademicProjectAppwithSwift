import SwiftUI

struct TeacherDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var projectViewModel = ProjectViewModel()

    var pendingProjects: [Project] {
        projectViewModel.projects.filter { $0.status == "proposal" }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if pendingProjects.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal")
                            .font(.system(size: 52))
                            .foregroundStyle(Color.appPrimary.opacity(0.5))

                        Text("Onay bekleyen yok")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Şu an incelemen gereken bir proje bulunmuyor.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(pendingProjects) { project in
                                pendingCard(for: project)
                                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                            }
                        }
                        .padding()
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: pendingProjects.count)
                    }
                }
            }
            .navigationTitle("Onay Bekleyenler")
            .task {
                await projectViewModel.fetchProjects()
            }
        }
    }

    private func pendingCard(for project: Project) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(project.title)
                .font(.headline)

            Text(project.summary ?? "Bu proje için özet girilmemiş.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

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
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color.statusApproved)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(BouncyButtonStyle())

                Button {
                    Task {
                        await projectViewModel.updateProjectStatus(
                            projectId: project.id ?? "",
                            newStatus: "rejected"
                        )
                    }
                } label: {
                    Label("Reddet", systemImage: "xmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.statusRejected)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color.statusRejected.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}
