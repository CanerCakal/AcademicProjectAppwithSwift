import Foundation
import FirebaseFirestore
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var errorMessage: String?
    
    var teachers: [User] {
        users.filter { $0.roleId == 2 }
    }
    
    private var db = Firestore.firestore()
    
    func fetchUsers() async {
        do {
            let snapshot = try await db.collection("users").getDocuments()
            self.users = snapshot.documents.compactMap { try? $0.data(as: User.self) }
        } catch {
            self.errorMessage = "Kullanıcılar yüklenirken hata oluştu: \(error.localizedDescription)"
        }
    }
    
    func updateUserRole(userId: String, newRoleId: Int) async {
        do {
            try await db.collection("users").document(userId).updateData([
                "roleId": newRoleId
            ])
            await fetchUsers()
        } catch {
            self.errorMessage = "Rol güncellenirken hata oluştu: \(error.localizedDescription)"
        }
    }
}
