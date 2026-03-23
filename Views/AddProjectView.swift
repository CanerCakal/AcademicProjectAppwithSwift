import SwiftUI

struct AddProjectView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var projectViewModel: ProjectViewModel
    
    // Yeni eklediğimiz CourseViewModel
    @StateObject private var courseViewModel = CourseViewModel()
    
    @State private var title = ""
    @State private var summary = ""
    @State private var selectedCourseId = "" // Artık sabit değil, kullanıcının seçtiği ID olacak
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ders Seçimi")) {
                    if courseViewModel.courses.isEmpty {
                        Text("Dersler yükleniyor veya bulunamadı...")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Bağlı Olduğu Ders", selection: $selectedCourseId) {
                            Text("Ders Seçiniz").tag("") // Varsayılan boş seçenek
                            
                            ForEach(courseViewModel.courses) { course in
                                Text("\(course.courseCode) - \(course.courseName)")
                                    .tag(course.id ?? "")
                            }
                        }
                    }
                }
                
                Section(header: Text("Proje Bilgileri")) {
                    TextField("Proje Başlığı", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if summary.isEmpty {
                            Text("Proje özeti ve detayları...")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $summary)
                            .frame(minHeight: 100)
                    }
                }
                
                Section {
                    Button(action: saveProject) {
                        Text("🚀 Projeyi Oluştur")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.blue)
                    // Başlık, özet VEYA ders seçilmemişse butonu kilitle!
                    .disabled(title.isEmpty || summary.isEmpty || selectedCourseId.isEmpty)
                }
            }
            .navigationTitle("Yeni Proje")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
            }
            // Sayfa açılır açılmaz dersleri veritabanından çek
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
                courseId: selectedCourseId, // Kullanıcının seçtiği dersin ID'sini gönderiyoruz
                createdBy: userId
            )
            dismiss()
        }
    }
}
