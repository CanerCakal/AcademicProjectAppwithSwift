import SwiftUI

struct ProjectDetailView: View {
    // Tıklanan projenin verilerini bu değişkene alacağız
    var project: Project
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                
                // 1. ÜST KISIM: Başlık ve Durum Rozeti
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
                
                // 3. ALT KISIM: Meta Bilgiler (Ders ve Öğrenci ID)
                VStack(alignment: .leading, spacing: 15) {
                    Label("Ders ID: \(project.courseId)", systemImage: "book.closed.fill")
                    
                    Label("Oluşturan (Öğrenci ID): \(project.createdBy)", systemImage: "person.fill")
                }
                .font(.callout)
                .foregroundColor(.gray)
                .padding(.top, 5)
                
                Spacer()
            }
            .padding(20)
        }
        .navigationTitle("Proje Detayı")
        .navigationBarTitleDisplayMode(.inline) // Başlığı ortada küçük gösterir
    }
    
    // Rozet Renklendirme Yardımcısı
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
