import SwiftUI

struct AddProjectView: View {
    @Environment(\.dismiss) var dismiss // Ekranı kapatmak için kullanacağız
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var projectViewModel: ProjectViewModel
    
    // Formdaki değişkenler
    @State private var title = ""
    @State private var summary = ""
    @State private var courseId = "DERS-101" // Şimdilik sabit, ileride dersleri çekip seçeceğiz
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Proje Bilgileri")) {
                    TextField("Proje Başlığı (Örn: Kütüphane Otomasyonu)", text: $title)
                    
                    // Daha geniş bir metin alanı (TextEditor)
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
                    Button(action: {
                        saveProject()
                    }) {
                        Text("🚀 Projeyi Oluştur")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.blue)
                    .disabled(title.isEmpty || summary.isEmpty) // Alanlar boşsa butonu kilitle
                }
            }
            .navigationTitle("Yeni Proje")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss() // Kapat
                    }
                }
            }
        }
    }
    
    // Kaydetme işlemi
    private func saveProject() {
        guard let user = authViewModel.currentUser, let userId = user.id else { return }
        
        Task {
            // ViewModel'deki fonksiyonu çağırıyoruz
            await projectViewModel.addProject(
                title: title,
                summary: summary,
                courseId: courseId,
                createdBy: userId // Giriş yapan kullanıcının ID'sini veriyoruz
            )
            dismiss() // İşlem bitince ekranı aşağı kaydırarak kapat
        }
    }
}
