import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProjectDetailViewModel()
    @EnvironmentObject var projectViewModel: ProjectViewModel
    @StateObject private var commentViewModel = CommentViewModel()
    
    @State private var newCommentText = ""
    @State private var currentStatus: ProjectStatus
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
    
    private var canApprove: Bool {
        isTeacher
        && currentStatus == .proposal
        && viewModel.course?.instructorId == authViewModel.currentUser?.id
    }
    
    private var canComment: Bool {
        isTeacher && viewModel.course?.instructorId == authViewModel.currentUser?.id
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(currentStatus.label)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(currentStatus.color.opacity(0.15))
                        .foregroundStyle(currentStatus.color)
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
                
                if canApprove {
                    teacherActions
                } else if isTeacher && currentStatus == .proposal {
                    notMyCourseNotice
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
                
                commentsSection
                
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
            commentViewModel.startListening(projectId: project.id ?? "")
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
                        newStatus: .approved
                    )
                    currentStatus = .approved
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
                        newStatus: .rejected
                    )
                    currentStatus = .rejected
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
    
    private var notMyCourseNotice: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.caption)
            Text("Bu dersin sorumlusu değilsiniz")
                .font(.subheadline)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var commentsSection: some View {
        infoCard {
            VStack(alignment: .leading, spacing: 16) {
                Label("Akademisyen Yorumları", systemImage: "text.bubble")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                
                if canComment {
                    VStack(spacing: 10) {
                        TextField("Yorum yaz...", text: $newCommentText, axis: .vertical)
                            .lineLimit(2, reservesSpace: true)
                            .padding(10)
                            .background(Color(UIColor.tertiarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Button {
                            let text = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !text.isEmpty,
                                  let user = authViewModel.currentUser,
                                  let userId = user.id else { return }
                            Task {
                                await commentViewModel.addComment(
                                    projectId: project.id ?? "",
                                    text: text,
                                    authorId: userId,
                                    authorName: user.fullName
                                )
                                newCommentText = ""
                            }
                        } label: {
                            Text("Gönder")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(Color.appPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(BouncyButtonStyle())
                        .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1)
                    }
                    
                    if !commentViewModel.comments.isEmpty {
                        Divider()
                    }
                }
                
                if commentViewModel.comments.isEmpty {
                    Text("Henüz yorum yapılmamış.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(spacing: 12) {
                        ForEach(commentViewModel.comments) { comment in
                            commentRow(comment)
                        }
                    }
                }
            }
        }
    }
    
    private func commentRow(_ comment: Comment) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.authorName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                Spacer()
                Text(comment.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(comment.text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
}
