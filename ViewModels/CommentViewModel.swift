import Foundation
import FirebaseFirestore
import Combine

@MainActor
class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    func fetchComments(projectId: String) async {
        do {
            let snapshot = try await db.collection("projects")
                .document(projectId)
                .collection("comments")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            self.comments = snapshot.documents.compactMap { try? $0.data(as: Comment.self) }
        } catch {
            self.errorMessage = "Yorumlar yüklenirken hata oluştu: \(error.localizedDescription)"
        }
    }
    
    func addComment(projectId: String, text: String, authorId: String, authorName: String) async {
        let newComment = Comment(
            text: text,
            authorId: authorId,
            authorName: authorName,
            createdAt: Date()
        )
        do {
            try db.collection("projects")
                .document(projectId)
                .collection("comments")
                .addDocument(from: newComment)
            try await db.collection("projects").document(projectId).updateData([
                "commentCount": FieldValue.increment(Int64(1))
            ])
            await fetchComments(projectId: projectId)
        } catch {
            self.errorMessage = "Yorum eklenirken hata oluştu: \(error.localizedDescription)"
        }
    }
}
