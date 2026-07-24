import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var projectViewModel = ProjectViewModel()
    @StateObject private var courseViewModel = CourseViewModel()
    
    @State private var showLogoutConfirm = false
    
    private var myProjects: [Project] {
        guard let myId = authViewModel.currentUser?.id else { return [] }
        return projectViewModel.projects.filter { $0.createdBy == myId }
    }
    
    private var myCourses: [Course] {
        guard let myId = authViewModel.currentUser?.id else { return [] }
        return courseViewModel.courses.filter { $0.instructorId == myId }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                if let user = authViewModel.currentUser {
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            VStack(spacing: 16) {
                                Circle()
                                    .fill(Color.appPrimary.opacity(0.15))
                                    .frame(width: 96, height: 96)
                                    .overlay(
                                        Text(initials(for: user.fullName))
                                            .font(.system(size: 34, weight: .semibold))
                                            .foregroundStyle(Color.appPrimary)
                                    )
                                
                                VStack(spacing: 6) {
                                    Text(user.fullName)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text(RoleResolver.roleName(for: user.roleId))
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color.appPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 5)
                                        .background(Color.appPrimary.opacity(0.12))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.top, 40)
                            
                            VStack(spacing: 0) {
                                infoRow(icon: "envelope.fill", label: "E-posta", value: user.email)
                                Divider().padding(.leading, 56)
                                infoRow(
                                    icon: "person.text.rectangle.fill",
                                    label: "Hesap Türü",
                                    value: RoleResolver.roleName(for: user.roleId)
                                )
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
                            .padding(.horizontal, 20)
                            
                            if user.roleId == 3 {
                                roleSection(
                                    title: "Projelerim",
                                    icon: "folder.fill",
                                    isEmpty: myProjects.isEmpty,
                                    emptyText: "Henüz proje oluşturmadın."
                                ) {
                                    ForEach(myProjects) { project in
                                        rowItem(
                                            title: project.title,
                                            subtitle: statusLabel(for: project.status.rawValue),
                                            accent: statusColor(for: project.status.rawValue)
                                        )
                                    }
                                }
                            }
                            
                            if user.roleId == 2 {
                                roleSection(
                                    title: "Sorumlu Olduğum Dersler",
                                    icon: "book.fill",
                                    isEmpty: myCourses.isEmpty,
                                    emptyText: "Henüz bir derse atanmadın."
                                ) {
                                    ForEach(myCourses) { course in
                                        rowItem(
                                            title: course.courseName,
                                            subtitle: "\(course.courseCode) · \(course.term)",
                                            accent: .appPrimary
                                        )
                                    }
                                }
                            }
                            
                            Button {
                                showLogoutConfirm = true
                            } label: {
                                Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.statusRejected)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.statusRejected.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(BouncyButtonStyle())
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle("Profilim")
            .task {
                await projectViewModel.fetchProjects()
                await courseViewModel.fetchCourses()
            }
            .alert("Çıkış Yap", isPresented: $showLogoutConfirm) {
                Button("Çıkış Yap", role: .destructive) {
                    authViewModel.logout()
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Hesabınızdan çıkmak istediğinize emin misiniz?")
            }
        }
    }
    
    private func roleSection<Content: View>(
        title: String,
        icon: String,
        isEmpty: Bool,
        emptyText: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
            
            if isEmpty {
                Text(emptyText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 8) {
                    content()
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
    
    private func rowItem(title: String, subtitle: String, accent: Color) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(accent)
                .frame(width: 4, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 42, height: 42)
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
        .padding(14)
    }
    
    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "approved": return .statusApproved
        case "development": return .statusDevelopment
        case "proposal": return .statusProposal
        case "rejected": return .statusRejected
        default: return .gray
        }
    }
    
    private func statusLabel(for status: String) -> String {
        switch status.lowercased() {
        case "approved": return "Onaylandı"
        case "development": return "Geliştirme"
        case "proposal": return "Öneri"
        case "rejected": return "Reddedildi"
        default: return status.capitalized
        }
    }
}
