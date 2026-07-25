import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthServiceProtocol {
    var currentUID: String? { get }
    func addAuthStateListener(_ handler: @escaping (String?) -> Void)
    func signIn(email: String, password: String) async throws -> String
    func createUser(email: String, password: String) async throws -> String
    func signOut() throws
    func fetchUserRecord(uid: String) async throws -> User?
    func createUserRecord(_ user: User, uid: String) throws
}

final class FirebaseAuthService: AuthServiceProtocol {
    private let db = Firestore.firestore()

    var currentUID: String? {
        Auth.auth().currentUser?.uid
    }

    func addAuthStateListener(_ handler: @escaping (String?) -> Void) {
        Auth.auth().addStateDidChangeListener { _, user in
            handler(user?.uid)
        }
    }

    func signIn(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }

    func createUser(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func fetchUserRecord(uid: String) async throws -> User? {
        let document = try await db.collection("users").document(uid).getDocument()
        guard document.exists else { return nil }
        return try document.data(as: User.self)
    }

    func createUserRecord(_ user: User, uid: String) throws {
        try db.collection("users").document(uid).setData(from: user)
    }
}
