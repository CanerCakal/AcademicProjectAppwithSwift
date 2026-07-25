import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?

    @Published var isLoading = false
    @Published var isCheckingAuth = true

    private let service: AuthServiceProtocol

    init(service: AuthServiceProtocol = FirebaseAuthService()) {
        self.service = service
        checkAuthSession()
    }

    private func checkAuthSession() {
        service.addAuthStateListener { [weak self] uid in
            guard let self = self else { return }

            if let uid = uid {
                Task {
                    await self.loadUserRecord(uid: uid)
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
            let uid = try await service.signIn(email: email, password: password)
            await loadUserRecord(uid: uid)
        } catch {
            self.errorMessage = "Giriş başarısız: \(error.localizedDescription)"
        }

        self.isLoading = false
    }

    private func loadUserRecord(uid: String) async {
        do {
            if let user = try await service.fetchUserRecord(uid: uid) {
                self.currentUser = user
                self.isAuthenticated = true
            } else {
                self.errorMessage = "Kullanıcı profili veritabanında bulunamadı."
                try? service.signOut()
            }
        } catch {
            self.errorMessage = "Bilgiler alınırken hata oluştu."
        }
    }

    func logout() {
        do {
            try service.signOut()
            self.isAuthenticated = false
            self.currentUser = nil
            self.errorMessage = nil
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
            let uid = try await service.createUser(email: email, password: password)

            let newUser = User(
                id: uid,
                fullName: fullName,
                email: email,
                roleId: RoleResolver.role(for: email),
                departmentId: departmentId
            )

            try service.createUserRecord(newUser, uid: uid)

            self.currentUser = newUser
            self.isAuthenticated = true
        } catch {
            self.errorMessage = "Kayıt başarısız: \(error.localizedDescription)"
        }

        self.isLoading = false
    }
}
