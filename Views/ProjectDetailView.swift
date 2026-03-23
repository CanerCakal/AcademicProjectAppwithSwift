import SwiftUI

struct ProjectDetailView: View {
    var project: Project
    
    // Yazdığımız yeni ViewModel'i ekliyoruz
    @StateObject private var viewModel = ProjectDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                
                // 1. ÜST KISIM: Başlık ve Durum
                HStack(alignment: .top) {
                    Text(project.title)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(project.status.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor(for: project.status))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.top, 5)
                }
                
                Divider()
                
                // 2. ORTA KISIM: Özet
                VStack(alignment: .leading, spacing: 10) {
                    Label("Proje Özeti", systemImage: "doc.text.fill")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(project.summary ?? "Bu proje için henüz bir özet girilmemiş.")
                        .font(.body)
                        .lineSpacing(6)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
                
                Divider()
                
                // 3. ALT KISIM: BİRLEŞTİRİLMİŞ VERİLER (JOIN)
                VStack(alignment: .leading, spacing: 20) {
                    Text("Bağlantılı Bilgiler")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if viewModel.isLoading {
                        // Veriler gelene kadar yükleniyor çarkı göster
                        ProgressView("Bilgiler getiriliyor...")
                    } else {
                        // GELEN DERS BİLGİSİ
                        HStack(spacing: 15) {
                            Image(systemName: "book.closed.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Ders")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                // Eğer ders bulunursa adını ve kodunu yaz, bulunamazsa hata mesajı yaz
                                if let course = viewModel.course {
                                    Text("\(course.courseCode) - \(course.courseName)")
                                        .font(.headline)
                                } else {
                                    Text("Ders bilgisi bulunamadı")
                                        .font(.subheadline)
                                        .italic()
                                }
                            }
                        }
                        
                        // GELEN ÖĞRENCİ BİLGİSİ
                        HStack(spacing: 15) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Oluşturan Öğrenci")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                // Eğer öğrenci bulunursa adını yaz
                                if let student = viewModel.student {
                                    Text(student.fullName)
                                        .font(.headline)
                                } else {
                                    Text("Öğrenci verisi silinmiş veya bulunamadı")
                                        .font(.subheadline)
                                        .italic()
                                }
                            }
                        }
                    }
                }
                .padding(.top, 5)
                
                Spacer()
            }
            .padding(20)
        }
        .navigationTitle("Proje Detayı")
        .navigationBarTitleDisplayMode(.inline)
        // Ekran açılır açılmaz ViewModel'deki fetchRelatedData fonksiyonunu çağır!
        .task {
            await viewModel.fetchRelatedData(courseId: project.courseId, studentId: project.createdBy)
        }
    }
    
    func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "approved": return .green
        case "development": return .orange
        case "proposal": return .blue
        case "rejected": return .red
        default: return .gray
        }
    }
}
