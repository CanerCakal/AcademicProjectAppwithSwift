import SwiftUI

struct AdminPanelView: View {
    @StateObject private var courseViewModel = CourseViewModel()
    @StateObject private var userViewModel = UserViewModel()

    @State private var selectedSection = 0

    @State private var courseCode = ""
    @State private var courseName = ""
    @State private var term = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Bölüm", selection: $selectedSection) {
                    Text("Dersler").tag(0)
                    Text("Kullanıcılar").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedSection == 0 {
                    coursesSection
                } else {
                    usersSection
                }
            }
            .navigationTitle("Yönetim")
            .task {
                await courseViewModel.fetchCourses()
                await userViewModel.fetchUsers()
            }
        }
    }

    private var coursesSection: some View {
        Form {
            Section("Yeni Ders Ekle") {
                TextField("Ders Kodu (örn. BIL101)", text: $courseCode)
                    .textInputAutocapitalization(.characters)
                TextField("Ders Adı", text: $courseName)
                TextField("Dönem (örn. 2025 Güz)", text: $term)

                Button {
                    Task {
                        await courseViewModel.addCourse(
                            courseCode: courseCode,
                            courseName: courseName,
                            term: term
                        )
                        courseCode = ""
                        courseName = ""
                        term = ""
                    }
                } label: {
                    Text("Dersi Ekle")
                }
                .disabled(courseCode.isEmpty || courseName.isEmpty || term.isEmpty)
            }

            Section("Mevcut Dersler") {
                if courseViewModel.courses.isEmpty {
                    Text("Henüz ders yok")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(courseViewModel.courses) { course in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(course.courseName)
                                .font(.headline)
                            Text("\(course.courseCode) · \(course.term)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private var usersSection: some View {
        List(userViewModel.users) { user in
            VStack(alignment: .leading, spacing: 8) {
                Text(user.fullName)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Rol", selection: Binding(
                    get: { user.roleId },
                    set: { newRole in
                        Task {
                            await userViewModel.updateUserRole(
                                userId: user.id ?? "",
                                newRoleId: newRole
                            )
                        }
                    }
                )) {
                    Text("Öğrenci").tag(3)
                    Text("Öğretmen").tag(2)
                    Text("Admin").tag(1)
                }
                .pickerStyle(.segmented)
            }
            .padding(.vertical, 4)
        }
    }
}
