import SwiftUI

struct AdminPanelView: View {
    @StateObject private var courseViewModel = CourseViewModel()
    @StateObject private var userViewModel = UserViewModel()
    
    @State private var selectedSection = 0
    
    @State private var courseCode = ""
    @State private var courseName = ""
    @State private var term = ""
    @State private var selectedInstructorId: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Bölüm", selection: $selectedSection) {
                    Text("Dersler").tag(0)
                    Text("Kullanıcılar").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                if selectedSection == 0 {
                    coursesSection
                } else {
                    usersSection
                }
            }
            .background(AppBackground())
            .navigationTitle("Yönetim")
            .tint(.appPrimary)
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
                    .onChange(of: courseCode) { courseViewModel.errorMessage = nil }
                    .textInputAutocapitalization(.characters)
                TextField("Ders Adı", text: $courseName)
                TextField("Dönem (örn. 2025 Güz)", text: $term)
                
                Picker("Akademisyen", selection: $selectedInstructorId) {
                    Text("Atanmadı").tag(String?.none)
                    ForEach(userViewModel.teachers) { teacher in
                        Text(teacher.fullName).tag(teacher.id as String?)
                    }
                }
                
                Button {
                    Task {
                        await courseViewModel.addCourse(
                            courseCode: courseCode,
                            courseName: courseName,
                            term: term,
                            instructorId: selectedInstructorId
                        )
                        if courseViewModel.errorMessage == nil {
                            courseCode = ""
                            courseName = ""
                            term = ""
                            selectedInstructorId = nil
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Label("Dersi Ekle", systemImage: "plus.circle.fill")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .foregroundStyle(Color.appPrimary)
                .disabled(courseCode.isEmpty || courseName.isEmpty || term.isEmpty)
                
                if let errorMessage = courseViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            
            Section("Mevcut Dersler") {
                if courseViewModel.courses.isEmpty {
                    Text("Henüz ders yok")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(courseViewModel.courses) { course in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "book.closed.fill")
                                    .foregroundStyle(Color.appPrimary)
                                    .frame(width: 28)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(course.courseName)
                                        .font(.subheadline.weight(.semibold))
                                    Text("\(course.courseCode) · \(course.term)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Picker("Akademisyen", selection: Binding(
                                get: { course.instructorId },
                                set: { newInstructor in
                                    Task {
                                        await courseViewModel.assignInstructor(
                                            courseId: course.id ?? "",
                                            instructorId: newInstructor
                                        )
                                    }
                                }
                            )) {
                                Text("Atanmadı").tag(String?.none)
                                ForEach(userViewModel.teachers) { teacher in
                                    Text(teacher.fullName).tag(teacher.id as String?)
                                }
                            }
                            .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
    
    private var usersSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(userViewModel.users) { user in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.appPrimary.opacity(0.15))
                                .frame(width: 42, height: 42)
                                .overlay(
                                    Text(initials(for: user.fullName))
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.appPrimary)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.fullName)
                                    .font(.subheadline.weight(.semibold))
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        
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
                    .padding(14)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding()
        }
    }
    
    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
