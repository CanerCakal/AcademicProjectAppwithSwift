import SwiftUI

struct AdminPanelView: View {
    @StateObject private var courseViewModel = CourseViewModel()

    @State private var courseCode = ""
    @State private var courseName = ""
    @State private var term = ""

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Yönetim")
            .task {
                await courseViewModel.fetchCourses()
            }
        }
    }
}
