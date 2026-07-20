import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    
    @Published var isLoading = false
    @Published var isCheckingAuth = true
    
    private var db = Firestore.firestore()
    
    init() {
        checkAuthSession()
    }
    
    private func checkAuthSession() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            if let user = user {
                Task {
                    await self.fetchUserRecord(uid: user.uid)
                    self.isCheckingAuth = false
                }
            } else {
                self.isAuthenticated = false
                self.currentUser = nil
                self.isCheckingAuth = false
            }
        }
    }
    
    func login(email: String, password: String) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            await fetchUserRecord(uid: authResult.user.uid)
        } catch {
            self.errorMessage = "Giriş başarısız: \(error.localizedDescription)"
        }
        
        self.isLoading = false
    }
    
    private func fetchUserRecord(uid: String) async {
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            if document.exists {
                self.currentUser = try document.data(as: User.self)
                self.isAuthenticated = true
            } else {
                self.errorMessage = "Kullanıcı profili veritabanında bulunamadı."
                try? Auth.auth().signOut()
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
    
    func register(fullName: String, email: String, password: String, departmentId: String?) async {
        guard RoleResolver.isValidInstitutionalEmail(email) else {
            self.errorMessage = "Kayıt için kurumsal üniversite e-posta adresinizi kullanmalısınız."
            return
        }
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            
            let newUser = User(
                id: uid,
                fullName: fullName,
                email: email,
                roleId: RoleResolver.role(for: email),
                departmentId: departmentId
            )
            
            try db.collection("users").document(uid).setData(from: newUser)
            
            
            self.currentUser = newUser
            self.isAuthenticated = true
            
        } catch {
            
            self.errorMessage = "Kayıt başarısız: \(error.localizedDescription)"
        }
        
        self.isLoading = false
    }
}
