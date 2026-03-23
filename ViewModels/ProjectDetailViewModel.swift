import Foundation
import FirebaseFirestore
import Combine

@MainActor
class ProjectDetailViewModel: ObservableObject {
    // Çektiğimiz verileri bu değişkenlerde tutacağız
    @Published var course: Course?
    @Published var student: User?
    @Published var isLoading = true // Yükleniyor animasyonu için
    
    private var db = Firestore.firestore()
    
    // Elimizdeki ID'leri kullanarak Firebase'den gerçek verileri çeken fonksiyon (İşte Join mantığımız!)
    func fetchRelatedData(courseId: String, studentId: String) async {
        // İki işlemi aynı anda başlatmak için do-catch kullanıyoruz
        do {
            // 1. Dersi Çek ("courses" koleksiyonundan o ID'ye sahip dokümanı bul)
            let courseDoc = try await db.collection("courses").document(courseId).getDocument()
            self.course = try? courseDoc.data(as: Course.self)
            
            // 2. Öğrenciyi Çek ("users" koleksiyonundan o ID'ye sahip dokümanı bul)
            let userDoc = try await db.collection("users").document(studentId).getDocument()
            self.student = try? userDoc.data(as: User.self)
            
        } catch {
            print("Veriler birleştirilirken hata oluştu: \(error.localizedDescription)")
        }
        
        // İşlem bitti, yükleniyor durumunu kapat
        self.isLoading = false
    }
}
