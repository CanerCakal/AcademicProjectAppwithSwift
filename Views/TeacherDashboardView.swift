import SwiftUI

struct TeacherDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var projectViewModel = ProjectViewModel()
    @StateObject private var courseViewModel = CourseViewModel()

    private var myCourseIds: [String] {
        guard let myId = authViewModel.currentUser?.id else { return [] }
        return courseViewModel.courses
            .filter { $0.ınstructorId == myId }
            .compactMap { $0.id }
    }

    private var pendingProjects: [Project] {
        projectViewModel.projects.filter { $0.status == "proposal" }
    }

    private func isMyCourse(_ project: Project) -> Bool {
        myCourseIds.contains(project.courseId)
    }

    private func courseCode(for courseId: String) -> String? {
        courseViewModel.courses.first { $0.id == courseId }?.courseCode
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if pendingProjects.isEmpty {
                    emptyState
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
                await courseViewModel.fetchCourses()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 52))
                .foregroundStyle(Color.appPrimary.opacity(0.5))

            Text("Onay bekleyen yok")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Şu an incelenecek bir proje bulunmuyor.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func pendingCard(for project: Project) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text(project.title)
                    .font(.headline)

                Spacer(minLength: 8)

                if let code = courseCode(for: project.courseId) {
                    Text(code)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.appPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.appPrimary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            Text(project.summary ?? "Bu proje için özet girilmemiş.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            if isMyCourse(project) {
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
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                    Text("Bu dersin sorumlusu değilsiniz")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}
