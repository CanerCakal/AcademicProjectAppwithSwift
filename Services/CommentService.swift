import Foundation
import FirebaseFirestore

protocol CommentServiceProtocol {
    func fetchComments(projectId: String) async throws -> [Comment]
    func addComment(projectId: String, comment: Comment) async throws
}

final class FirestoreCommentService: CommentServiceProtocol {
    private let db = Firestore.firestore()

    private func commentsRef(for projectId: String) -> CollectionReference {
        db.collection("projects").document(projectId).collection("comments")
    }

    func fetchComments(projectId: String) async throws -> [Comment] {
        let snapshot = try await commentsRef(for: projectId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Comment.self) }
    }

    func addComment(projectId: String, comment: Comment) async throws {
        try commentsRef(for: projectId).addDocument(from: comment)
        try await db.collection("projects").document(projectId).updateData([
            "commentCount": FieldValue.increment(Int64(1))
        ])
    }
}
