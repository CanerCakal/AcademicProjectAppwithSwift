import SwiftUI

struct ProjectDetailView: View {
    let project: Project

    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProjectDetailViewModel()
    @StateObject private var projectViewModel = ProjectViewModel()

    @State private var currentStatus: String
    @State private var showEditSheet = false

    init(project: Project) {
        self.project = project
        _currentStatus = State(initialValue: project.status)
    }

    private var isOwner: Bool {
        project.createdBy == authViewModel.currentUser?.id
    }

    private var isTeacher: Bool {
        authViewModel.currentUser?.roleId == 2
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading, spacing: 12) {
                    Text(statusLabel(for: currentStatus))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(statusColor(for: currentStatus).opacity(0.15))
                        .foregroundStyle(statusColor(for: currentStatus))
                        .clipShape(Capsule())

                    Text(project.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                }

                infoCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Proje Özeti", systemImage: "doc.text")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appPrimary)

                        Text(project.summary ?? "Bu proje için henüz bir özet girilmemiş.")
                            .font(.body)
                            .lineSpacing(5)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                infoCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Bağlantılı Bilgiler")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appPrimary)

                        if viewModel.isLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("Bilgiler getiriliyor...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            detailRow(
                                icon: "book.closed.fill",
                                label: "Ders",
                                value: viewModel.course.map { "\($0.courseCode) · \($0.courseName)" }
                                    ?? "Ders bilgisi bulunamadı"
                            )

                            Divider()

                            detailRow(
                                icon: "person.fill",
                                label: "Oluşturan",
                                value: viewModel.student?.fullName ?? "Kullanıcı bulunamadı"
                            )
                        }
                    }
                }

                if isTeacher && currentStatus == "proposal" {
                    teacherActions
                }

                if isOwner {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Projeyi Düzenle", systemImage: "pencil")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.appPrimary.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(BouncyButtonStyle())
                }

                Spacer(minLength: 20)
            }
            .padding(20)
        }
        .background(AppBackground())
        .navigationTitle("Proje Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeOut(duration: 0.25), value: currentStatus)
        .task {
            await viewModel.fetchRelatedData(
                courseId: project.courseId,
                studentId: project.createdBy
            )
        }
        .sheet(isPresented: $showEditSheet) {
            EditProjectView(project: project)
                .environmentObject(projectViewModel)
        }
    }

    private var teacherActions: some View {
        HStack(spacing: 12) {
            Button {
                Task {
                    await projectViewModel.updateProjectStatus(
                        projectId: project.id ?? "",
                        newStatus: "approved"
                    )
                    currentStatus = "approved"
                }
            } label: {
                Label("Onayla", systemImage: "checkmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.statusApproved)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(BouncyButtonStyle())

            Button {
                Task {
                    await projectViewModel.updateProjectStatus(
                        projectId: project.id ?? "",
                        newStatus: "rejected"
                    )
                    currentStatus = "rejected"
                }
            } label: {
                Label("Reddet", systemImage: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.statusRejected)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.statusRejected.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(BouncyButtonStyle())
        }
    }

    private func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 32, height: 32)
                .background(Color.appPrimary.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.medium))
            }

            Spacer()
        }
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
