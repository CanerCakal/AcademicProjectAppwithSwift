import Foundation
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var errorMessage: String?

    var teachers: [User] {
        users.filter { $0.roleId == RoleResolver.teacherRole }
    }

    private let service: UserServiceProtocol

    init(service: UserServiceProtocol = FirestoreUserService()) {
        self.service = service
    }

    func fetchUsers() async {
        do {
            self.users = try await service.fetchUsers()
        } catch {
            self.errorMessage = "Kullanıcılar yüklenirken hata oluştu: \(error.localizedDescription)"
        }
    }

    func updateUserRole(userId: String, newRoleId: Int) async {
        do {
            try await service.updateUserRole(userId: userId, newRoleId: newRoleId)
            await fetchUsers()
        } catch {
            self.errorMessage = "Rol güncellenirken hata oluştu: \(error.localizedDescription)"
        }
    }
}
