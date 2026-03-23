import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    
    // YENİ: Arayüzde "Yükleniyor" ikonlarını göstermek için
    @Published var isLoading = false
    // YENİ: Uygulama ilk açıldığında hafızayı kontrol ederken ekranda Login sayfasının anlık parlamasını engellemek için
    @Published var isCheckingAuth = true
    
    private var db = Firestore.firestore()
    
    // Uygulama açıldığı an (veya bu sınıf oluşturulduğu an) çalışacak ilk kod
    init() {
        checkAuthSession()
    }
    
    // Firebase'in hafızasında açık bir oturum var mı diye dinleyen fonksiyon
    private func checkAuthSession() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            if let user = user {
                // Hafızada kullanıcı var! Hemen Firestore'dan rolünü (Admin/Öğrenci) çek
                Task {
                    await self.fetchUserRecord(uid: user.uid)
                    self.isCheckingAuth = false // Kontrol bitti
                }
            } else {
                // Hafızada kullanıcı yok, Login ekranını göster
                self.isAuthenticated = false
                self.currentUser = nil
                self.isCheckingAuth = false // Kontrol bitti
            }
        }
    }
    
    func login(email: String, password: String) async {
        self.isLoading = true // Butona basıldı, yükleniyor ikonunu yak!
        self.errorMessage = nil
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            await fetchUserRecord(uid: authResult.user.uid)
        } catch {
            self.errorMessage = "Giriş başarısız: \(error.localizedDescription)"
        }
        
        self.isLoading = false // İşlem bitti, ikonu söndür
    }
    
    private func fetchUserRecord(uid: String) async {
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            if document.exists {
                self.currentUser = try document.data(as: User.self)
                self.isAuthenticated = true
            } else {
                self.errorMessage = "Kullanıcı profili veritabanında bulunamadı."
                try? Auth.auth().signOut() // Hata varsa sahte oturumu kapat
            }
        } catch {
            self.errorMessage = "Bilgiler alınırken hata oluştu."
        }
    }
    
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
