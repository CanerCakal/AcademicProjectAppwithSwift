import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var projectViewModel = ProjectViewModel()
    @StateObject private var courseViewModel = CourseViewModel()
    
    @State private var showingAddProject = false
    @State private var projectToEdit: Project?
    @State private var selectedCourseId: String? = nil
    @State private var hasAppeared = false
    
    private var filteredProjects: [Project] {
        guard let selectedCourseId else { return projectViewModel.projects }
        return projectViewModel.projects.filter { $0.courseId == selectedCourseId }
    }
    
    private var approvedCount: Int {
        projectViewModel.projects.filter { $0.status == "approved" }.count
    }
    
    private var pendingCount: Int {
        projectViewModel.projects.filter { $0.status == "proposal" }.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                VStack(spacing: 0) {
                    if !projectViewModel.projects.isEmpty {
                        summaryStrip
                        courseFilterBar
                    }
                    
                    if filteredProjects.isEmpty {
                        Spacer()
                        emptyState
                        Spacer()
                    } else {
                        projectList
                    }
                }
                
                floatingAddButton
            }
            .navigationTitle("Projeler")
            .task {
                await projectViewModel.fetchProjects()
                await courseViewModel.fetchCourses()
                hasAppeared = true
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
    
    private var summaryStrip: some View {
        HStack(spacing: 12) {
            summaryPill(
                value: projectViewModel.projects.count,
                label: "Toplam",
                color: .appPrimary
            )
            summaryPill(
                value: approvedCount,
                label: "Onaylı",
                color: .statusApproved
            )
            summaryPill(
                value: pendingCount,
                label: "Beklemede",
                color: .statusProposal
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private func summaryPill(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text("\(value)")
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var courseFilterBar: some View {
        Menu {
            Button {
                selectedCourseId = nil
            } label: {
                Label("Tüm Dersler", systemImage: selectedCourseId == nil ? "checkmark" : "")
            }
            
            ForEach(courseViewModel.courses) { course in
                Button {
                    selectedCourseId = course.id
                } label: {
                    Label(
                        "\(course.courseCode) · \(course.courseName)",
                        systemImage: selectedCourseId == course.id ? "checkmark" : ""
                    )
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                Text(selectedFilterLabel)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color.appPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.appPrimary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    private var selectedFilterLabel: String {
        guard let selectedCourseId,
              let course = courseViewModel.courses.first(where: { $0.id == selectedCourseId })
        else {
            return "Tüm Dersler"
        }
        return "\(course.courseCode) · \(course.courseName)"
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: selectedCourseId == nil ? "folder.badge.plus" : "line.3.horizontal.decrease.circle")
                .font(.system(size: 52))
                .foregroundStyle(Color.appPrimary.opacity(0.5))
            
            Text(selectedCourseId == nil ? "Henüz proje yok" : "Bu derste proje yok")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(selectedCourseId == nil
                 ? "İlk projeni oluşturmak için sağ alttaki butona dokun."
                 : "Bu derse ait henüz bir proje eklenmemiş.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
        }
    }
    
    private var projectList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(Array(filteredProjects.enumerated()), id: \.element.id) { index, project in
                    NavigationLink(destination: ProjectDetailView(project: project)) {
                        ProjectCardView(
                            project: project,
                            courseCode: courseCode(for: project.courseId)
                        )
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
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 20)
                    .animation(
                        .easeOut(duration: 0.35).delay(Double(index) * 0.05),
                        value: hasAppeared
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 90)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: filteredProjects.count)
        }
    }
    
    private func courseCode(for courseId: String) -> String? {
        courseViewModel.courses.first { $0.id == courseId }?.courseCode
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
    var courseCode: String?
    
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
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let courseCode {
                HStack(spacing: 6) {
                    Image(systemName: "book.closed.fill")
                        .font(.caption2)
                    Text(courseCode)
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(Color.appPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.appPrimary.opacity(0.1))
                .clipShape(Capsule())
            }
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
