import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var projectViewModel = ProjectViewModel()

    @State private var showingAddProject = false
    @State private var projectToEdit: Project?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                if projectViewModel.projects.isEmpty {
                    emptyState
                } else {
                    projectList
                }

                floatingAddButton
            }
            .navigationTitle("Projeler")
            .task {
                await projectViewModel.fetchProjects()
            }
            .sheet(isPresented: $showingAddProject) {
                AddProjectView(projectViewModel: projectViewModel)
            }
            .sheet(item: $projectToEdit) { project in
                EditProjectView(project: project)
                    .environmentObject(projectViewModel)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 52))
                .foregroundStyle(Color.appPrimary.opacity(0.5))

            Text("Henüz proje yok")
                .font(.title3)
                .fontWeight(.semibold)

            Text("İlk projeni oluşturmak için sağ alttaki butona dokun.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var projectList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(projectViewModel.projects) { project in
                    NavigationLink(destination: ProjectDetailView(project: project)) {
                        ProjectCardView(project: project)
                    }
                    .buttonStyle(CardButtonStyle())
                    .contextMenu {
                        if project.createdBy == authViewModel.currentUser?.id {
                            Button {
                                projectToEdit = project
                            } label: {
                                Label("Düzenle", systemImage: "pencil")
                            }

                            Button(role: .destructive) {
                                Task {
                                    await projectViewModel.deleteProject(projectId: project.id ?? "")
                                }
                            } label: {
                                Label("Sil", systemImage: "trash")
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding()
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: projectViewModel.projects.count)
        }
    }

    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                if let user = authViewModel.currentUser, user.roleId == 3 {
                    Button {
                        showingAddProject = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 58, height: 58)
                            .background(Color.appPrimary)
                            .clipShape(Circle())
                            .shadow(color: Color.appPrimary.opacity(0.35), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .padding(20)
                }
            }
        }
    }
}

struct ProjectCardView: View {
    var project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(project.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                Text(statusLabel(for: project.status))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(statusColor(for: project.status).opacity(0.15))
                    .foregroundStyle(statusColor(for: project.status))
                    .clipShape(Capsule())
            }

            Text(project.summary ?? "Bu proje için henüz bir özet girilmemiş.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "approved": return .statusApproved
        case "development": return .statusDevelopment
        case "proposal": return .statusProposal
        case "rejected": return .statusRejected
        default: return .gray
        }
    }

    func statusLabel(for status: String) -> String {
        switch status.lowercased() {
        case "approved": return "Onaylandı"
        case "development": return "Geliştirme"
        case "proposal": return "Öneri"
        case "rejected": return "Reddedildi"
        default: return status.capitalized
        }
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
