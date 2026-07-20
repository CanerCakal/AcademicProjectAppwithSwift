import SwiftUI

struct AddProjectView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var projectViewModel: ProjectViewModel
    
    @StateObject private var courseViewModel = CourseViewModel()
    
    @State private var title = ""
    @State private var summary = ""
    @State private var selectedCourseId = ""
    
    private var isFormValid: Bool {
        !title.isEmpty && !summary.isEmpty && !selectedCourseId.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Ders Seçimi") {
                    if courseViewModel.courses.isEmpty {
                        HStack(spacing: 8) {
                            ProgressView()
                            Text("Dersler yükleniyor...")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Picker("Bağlı Olduğu Ders", selection: $selectedCourseId) {
                            Text("Ders Seçiniz").tag("")
                            ForEach(courseViewModel.courses) { course in
                                Text("\(course.courseCode) · \(course.courseName)")
                                    .tag(course.id ?? "")
                            }
                        }
                    }
                }
                
                Section("Proje Bilgileri") {
                    TextField("Proje Başlığı", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if summary.isEmpty {
                            Text("Proje özeti ve detayları...")
                                .foregroundStyle(Color(UIColor.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $summary)
                            .frame(minHeight: 110)
                    }
                }
                
                Section {
                    Button(action: saveProject) {
                        HStack {
                            Spacer()
                            Text("Projeyi Oluştur")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(isFormValid ? Color.appPrimary : Color.appPrimary.opacity(0.4))
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Yeni Proje")
            .navigationBarTitleDisplayMode(.inline)
            .tint(.appPrimary)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("İptal") { dismiss() }
                }
            }
            .task {
                await courseViewModel.fetchCourses()
            }
        }
    }
    
    private func saveProject() {
        guard let user = authViewModel.currentUser, let userId = user.id else { return }
        
        Task {
            await projectViewModel.addProject(
                title: title,
                summary: summary,
                courseId: selectedCourseId,
                createdBy: userId
            )
            dismiss()
        }
    }
}
