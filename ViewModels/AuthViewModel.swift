import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

// @MainActor, buradaki işlemlerin arayüzü güncelleyeceğini ve ana işlemcide çalışması gerektiğini belirtir.
@MainActor
class AuthViewModel: ObservableObject {
    
    // @Published ile işaretlenen değişkenler değiştiğinde, ekrandaki arayüz otomatik olarak yenilenir.
    @Published var currentUser: User? // Bir önceki adımda oluşturduğumuz kendi User modelimiz
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    // Giriş yapma fonksiyonu (async kullanarak uygulamanın donmasını engelliyoruz)
    func login(email: String, password: String) async {
        do {
            // 1. Firebase Auth ile şifre kontrolü yap
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let firebaseUser = authResult.user
            
            // 2. Şifre doğruysa, Firestore veritabanından kullanıcının rolü (Admin/Hoca/Öğrenci) gibi detaylarını çek
            await fetchUserRecord(uid: firebaseUser.uid)
            
        } catch {
            self.errorMessage = error.localizedDescription // Hata olursa ekrana basmak için değişkene atıyoruz
        }
    }
    
    // Veritabanından kullanıcı detaylarını çeken yardımcı fonksiyon
    private func fetchUserRecord(uid: String) async {
        do {
            // Firestore'daki "users" koleksiyonunda bu UID'ye sahip dokümanı bul
            let document = try await db.collection("users").document(uid).getDocument()
            
            if document.exists {
                // Sihirli kısım: Veritabanındaki veriyi bizim User.swift struct'ına otomatik çevir!
                self.currentUser = try document.data(as: User.self)
                self.isAuthenticated = true
            } else {
                self.errorMessage = "Kullanıcı profili veritabanında bulunamadı."
            }
        } catch {
            self.errorMessage = "Bilgiler alınırken hata oluştu."
        }
    }
    
    // Çıkış yapma fonksiyonu
    func logout() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch {
            print("Çıkış hatası: \(error.localizedDescription)")
        }
    }
}
