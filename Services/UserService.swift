import Foundation
import FirebaseFirestore

protocol UserServiceProtocol {
    func fetchUsers() async throws -> [User]
    func updateUserRole(userId: String, newRoleId: Int) async throws
}

final class FirestoreUserService: UserServiceProtocol {
    private let db = Firestore.firestore()
    private let collectionName = "users"

    func fetchUsers() async throws -> [User] {
        let snapshot = try await db.collection(collectionName).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: User.self) }
    }

    func updateUserRole(userId: String, newRoleId: Int) async throws {
        try await db.collection(collectionName).document(userId).updateData([
            "roleId": newRoleId
        ])
    }
}
